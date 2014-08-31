require 'spec_helper'

describe SpecApib::Blueprint do

  subject do
    described_class.new example_apib_source
  end

  before do
    allow(RedSnow).to receive(:parse).and_return(example_apib)
  end

  describe '#initialize' do

    it 'calls RedSnow::parse' do
      subject
      expect(RedSnow).to have_received(:parse).with(example_apib_source)
    end

    it 'has a #metadata getter' do
      expect(subject.metadata).to eql(example_apib.ast.metadata)
    end

    it 'has a #apib getter' do
      expect(subject.apib).to eql(example_apib.ast)
    end
  end
end