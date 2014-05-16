require 'spec_helper'

describe Jasmine::Runners::Phantom do
  let!(:port) { 8888 }
  let!(:results_processor) do
    double('results_processor').tap do |processor|
      processor.stub :process
    end
  end
  let!(:result_batch_size) { Object.new }

  subject do
    Jasmine::Runners::Phantom.new port, results_processor, result_batch_size
  end

  describe '#run' do
    let(:messages) { {'messages' => [{'passed' => true, 'type' => 'expect', 'message' => 'Passed.', 'trace' => {}}]} }
    let(:describe1) do
      {'id' => 1, 'description' => 'foo'}
    end

    let(:describe2) do
      {'id' => 2, 'description' => 'bar'}
    end

    let(:json) do
      {
        'top_level_suites' => [describe1],
        'suites' => [describe1, describe2]
      }
    end

    let(:tempfile) do
      mock('tempfile').tap do |f|
        f.should_receive(:read).and_return(describe1)
        f.should_receive(:close)
      end
    end

    before do
      Process.should_receive :spawn
      Process.should_receive :wait
    end

    describe '#load_suite_info' do
      before do
        JSON.should_receive(:parse).and_return json
        subject.should_receive(:results_hash).and_return {}
        subject.run
      end
      its(:suites) do
        should == [describe1, describe2]
      end
    end
  end
end