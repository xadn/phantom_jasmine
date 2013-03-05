require 'facter'
require 'jasmine'
require 'tempfile'
require 'phantomjs'

class Jasmine::Runners::Phantom
  attr_accessor :suites

  def initialize(port, results_processor, result_batch_size)
    @port = port
    @results_processor = results_processor
    @result_batch_size = result_batch_size
    @phantom = Phantomjs.path
  end

  def run
    load_suite_info
    @results_processor.process(results_hash, suites)
  end

  private

  def load_suite_info
    tmpfile = Tempfile.new('count')
    pid = Process.spawn "#{@phantom} '#{File.join(File.dirname(__FILE__), 'phantom_jasmine_count.js')}' #{@port}", :out => tmpfile.path
    Process.wait pid
    json = JSON.parse(tmpfile.read, :max_nesting => 100).tap { tmpfile.close }
    @suites = json['suites']
    @top_level_suites = json['top_level_suites']
  end

  def run_suites(suites)
    tmpfile = Tempfile.new('run')
    commands = suites.map do |suite|
      "#{@phantom} '#{File.join(File.dirname(__FILE__), 'phantom_jasmine_run.js')}' #{@port} '#{suite['description']}'"
    end.join(';echo ,;')

    pid = Process.spawn "echo [;#{commands};echo ]", :out => tmpfile.path
    [pid, tmpfile]
  end

  def results_hash
    spec_results = {}
    @top_level_suites.group_by { |suite| suite['id'] % processor_count }.map { |(k, suites)| run_suites(suites) }.each do |pid, tmpfile|
      Process.wait pid

      JSON.parse(tmpfile.read).each do |result|
        result.each do |spec_id, spec_result|
          spec_results.merge! spec_id => spec_result unless spec_result['messages'].empty?
        end
      end

      tmpfile.close
    end

    spec_results
  end

  def processor_count
    @processor_count ||= begin
      ENV['JASMINE_PARALLEL_COUNT'] || Facter.processorcount
    end.to_i
  end
end
