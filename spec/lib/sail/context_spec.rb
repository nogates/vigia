require 'spec_helper'

describe Vigia::Sail::Context do

  let(:options)                 { { } }
  let(:rspec_context)           { double(described_class: testing_described_class) }
  let(:testing_described_class) { double }

  subject do
    described_class.new :example_name, options, rspec_context
  end

  describe '#to_s' do
    it 'outputs the context name' do
      expect(subject.to_s).to eql('context example_name')
    end
  end
end
