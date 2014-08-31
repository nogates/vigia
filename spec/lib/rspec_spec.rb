require 'spec_helper'

describe SpecApib::Rspec do

  describe '#run!' do
    before do
      allow(RSpec::Core::Runner).to receive(:run)
      allow(SpecApib).to receive(:spec_folder).and_return('spec_folder')
      subject.run!
    end

    it 'calls the rspec to run the specfolder' do
      expect(RSpec::Core::Runner).to have_received(:run)
        .with(['spec_folder'], $stderr, $stdout).once
    end
  end
end
