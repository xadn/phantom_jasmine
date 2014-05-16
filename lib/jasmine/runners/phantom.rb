require 'facter'
require 'jasmine'
require 'tempfile'
require 'phantomjs'

class Jasmine::Runners::Phantom

  def initialize(port, results_processor, result_batch_size)
    @port = port
    @results_processor = results_processor
    @result_batch_size = result_batch_size
    @phantom = Phantomjs.path
  end

  def run
    @results_processor.process(results_hash, suites)
  end

  def suites
    selected_groups.flatten
  end

  private

  def available_suites
    @available_suites ||= begin
      tmpfile = Tempfile.new('count')
      pid = Process.spawn "#{@phantom} '#{File.join(File.dirname(__FILE__), 'phantom_jasmine_count.js')}' #{@port}", :out => tmpfile.path
      Process.wait pid
      json = JSON.parse(tmpfile.read, :max_nesting => 100).tap { tmpfile.close }
      json['suites']
    end
  end

  def run_suites(suites)
    tmpfile = Tempfile.new('run')
    commands = suites.map do |suite|
      "#{@phantom} '#{File.join(File.dirname(__FILE__), 'phantom_jasmine_run.js')}' #{@port} '#{suite['name']}'"
    end.join(';echo ,;')

    pid = Process.spawn "echo [;#{commands};echo ]", :out => tmpfile.path
    [pid, tmpfile]
  end

  def selected_groups
    group_size = (available_suites.size.to_f / parallel_count.to_f).ceil
    groups = available_suites.each_slice(group_size).to_a
    selected_group_indexes.map { |index| Array(groups[index - 1]) }
  end

  def results_hash
    spec_results = {}
    selected_groups.map { |suites| run_suites(suites) }.each do |pid, tmpfile|
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

  def parallel_count
    @parallel_count ||= begin
      ENV['JASMINE_PARALLEL_COUNT'] || Facter[:processorcount].value
    end.to_i
  end

  def selected_group_indexes
    ENV['JASMINE_SELECT_GROUPS'] ? ENV['JASMINE_SELECT_GROUPS'].split(',').map(&:to_i) : (1..parallel_count)
  end
end
