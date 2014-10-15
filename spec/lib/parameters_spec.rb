require 'spec_helper'

describe Vigia::Parameters do

  include_examples "redsnow doubles"

  subject do
    described_class.new resource, action
  end

  describe '#initialize' do
    it 'creates a new Vigia::Parameters instance' do
      expect(subject).to be_a(Vigia::Parameters)
    end
    it 'creates #resource getter' do
      expect(subject.resource).to be(resource)
    end
    it 'creates #action getter' do
      expect(subject.action).to be(action)
    end
  end

  describe '#to_hash' do
    let(:resource_parameter_one_name)          { 'place' }
    let(:resource_parameter_one_example_value) { 'the-world' }
    let(:action_parameter_one_name)            { 'time' }
    let(:action_parameter_one_example_value)   { 'now' }

    it 'returns the expected parameters in a hash instance' do
      hash = { 'place' => 'the-world', 'time' => 'now' }
      expect(subject.to_hash).to eql(hash)
    end
  end
end
