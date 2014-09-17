require 'spec_helper'

describe Vigia::Blueprint do

  subject do
    described_class.new Vigia::ExampleTest.apib_source
  end

  before do
    allow(RedSnow).to receive(:parse).and_return(Vigia::ExampleTest.apib)
  end

  describe '#initialize' do

    it 'calls RedSnow::parse' do
      subject
      expect(RedSnow).to have_received(:parse).with(Vigia::ExampleTest.apib_source)
    end

    it 'has a #metadata getter' do
      expect(subject.metadata).to eql(Vigia::ExampleTest.apib.ast.metadata)
    end

    it 'has a #apib getter' do
      expect(subject.apib).to eql(Vigia::ExampleTest.apib.ast)
    end
  end
end
