require 'spec_helper'

describe SpecApib::Blueprint do

  subject do
    described_class.new SpecApib::ExampleTest.apib_source
  end

  before do
    allow(RedSnow).to receive(:parse).and_return(SpecApib::ExampleTest.apib)
  end

  describe '#initialize' do

    it 'calls RedSnow::parse' do
      subject
      expect(RedSnow).to have_received(:parse).with(SpecApib::ExampleTest.apib_source)
    end

    it 'has a #metadata getter' do
      expect(subject.metadata).to eql(SpecApib::ExampleTest.apib.ast.metadata)
    end

    it 'has a #apib getter' do
      expect(subject.apib).to eql(SpecApib::ExampleTest.apib.ast)
    end
  end
end
