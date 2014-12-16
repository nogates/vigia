require 'spec_helper'

describe Vigia::Rspec do
  let(:config) do
    instance_double(
      Vigia::Config,
      stdout: stdout,
      stderr: stderr,
      rspec_config_block: nil
    )
  end
  let(:stdout) { $stdout }
  let(:stderr) { $stderr }

  before do
    allow(Vigia).to receive(:config).and_return(config)
  end


  describe '::include_shared_folders' do
    before do
      allow(described_class).to receive(:require)
      allow(config).to receive(:custom_examples_paths).and_return([ 'a', 'b' ])
    end

    after do
      described_class.include_shared_folders
    end

    it 'requires the utils file' do
      expect(described_class).to receive(:require).with(/vigia\/lib\/vigia\/spec\/support\/utils$/)
    end

    it 'requires the custom_examples_paths' do
      expect(described_class).to receive(:require).with('a')
      expect(described_class).to receive(:require).with('b')
    end
  end

  describe '#run!' do
    let(:stdout) { 'output' }
    let(:stderr) { 'error output' }

    before do
      allow(RSpec::Core::Runner).to receive(:run)
      allow(Vigia).to receive(:spec_folder).and_return('spec_folder')
      allow(subject).to receive(:configure_vigia_rspec)
      subject.run!
    end

    it 'calls the rspec to run the spec folder with the right options' do
      expect(RSpec::Core::Runner).to have_received(:run)
        .with(['spec_folder'], 'error output', 'output').once
    end
  end
end
