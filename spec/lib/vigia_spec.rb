require 'spec_helper'

describe Vigia do
  let(:rspec) do
    instance_double(Vigia::Rspec, run!: nil)
  end
  before do
    allow(Vigia::Rspec).to receive(:new).and_return(rspec)
  end

  describe '::rspec!' do
    it 'creates a new Vigia::Rspec instance and runs it' do
      expect(rspec).to receive(:run!)
      described_class.rspec!
    end
  end
end
