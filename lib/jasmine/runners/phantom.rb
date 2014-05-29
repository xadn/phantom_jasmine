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
    node_suites
  end

  private

  def results_hash
    spec_results = {}
    puts "Running #{parallel_suite_groups.flatten.size} suites across #{parallel_suite_groups.size} threads"
    parallel_suite_groups.map { |suites| run_suites(suites) }.each do |pid, tmpfile|
      Process.wait pid
      puts "pid: #{pid} has finished"

      JSON.parse(tmpfile.read).each do |result|
        result.each do |spec_id, spec_result|
          spec_results.merge! spec_id => spec_result unless spec_result['messages'].empty?
        end
      end

      tmpfile.close
    end

    spec_results
  end

  def run_suites(suites)
    tmpfile = Tempfile.new('run')
    commands = suites.map do |suite|
      "#{@phantom} '#{File.join(File.dirname(__FILE__), 'phantom_jasmine_run.js')}' #{@port} '#{suite['name']}'"
    end.join(';echo ,;')

    pid = Process.spawn "echo [;#{commands};echo ]", :out => tmpfile.path
    [pid, tmpfile]
  end

  def parallel_suite_groups
    node_suites.each_slice(suites_per_processor).to_a
  end

  def suites_per_processor
    (node_suites.size.to_f / processor_count.to_f).ceil
  end

  def node_suites
    @node_suites ||= begin
      Array(Array(suites_by_node[node_index]))
    end
  end

  def suites_by_node
    all_suites.each_slice(suites_per_node).to_a
  end

  def suites_per_node
    (all_suites.size.to_f / node_total.to_f).ceil
  end

  def all_suites
    @all_suites ||= begin
      tmpfile = Tempfile.new('count')
      pid = Process.spawn "#{@phantom} '#{File.join(File.dirname(__FILE__), 'phantom_jasmine_count.js')}' #{@port}", :out => tmpfile.path
      Process.wait pid
      json = JSON.parse(tmpfile.read, :max_nesting => 100).tap { tmpfile.close }
      json['suites'].shuffle(random: Random.new(1))
    end
  end

  def processor_count
    @processor_count ||= begin
      ENV['JASMINE_PARALLEL_COUNT'] || Facter[:processorcount].value
    end.to_i
  end

  def node_total
    @node_total ||= begin
      ENV['JASMINE_NODE_TOTAL'] || ENV['CIRCLE_NODE_TOTAL'] || 1
    end.to_i
  end

  def node_index
    @node_index ||= begin
      ENV['JASMINE_NODE_INDEX'] || ENV['CIRCLE_NODE_INDEX'] || 0
    end.to_i
  end
end