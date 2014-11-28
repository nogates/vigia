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

  describe '#run!' do
    let(:stdout) { 'output' }
    let(:stderr) { 'error output' }

    before do
      allow(RSpec::Core::Runner).to receive(:run)
      allow(Vigia).to receive(:spec_folder).and_return('spec_folder')
      subject.run!
    end

    it 'calls the rspec to run the specfolder with the right options' do
      expect(RSpec::Core::Runner).to have_received(:run)
        .with(['spec_folder'], 'error output', 'output').once
    end
  end
end
