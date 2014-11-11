require 'spec_helper'

describe Vigia::Parameters do

  include_examples "redsnow doubles"

  let(:parameters_hash) do
    [
      { name: 'scenario_slug', value: 'scenario_one', required: true },
      { name: 'page', value: '3', required: false }
    ]
  end

  subject do
    described_class.new parameters_hash
  end

  describe '#initialize' do
    it 'creates a new Vigia::Parameters instance' do
      expect(subject).to be_a(Vigia::Parameters)
    end
    it 'creates #parameters getter' do
      expect(subject.parameters).to be(parameters_hash)
    end
  end

  describe '#to_hash' do
    it 'returns the expected parameters in a hash instance' do
      hash = { 'scenario_slug' => 'scenario_one', 'page' => '3' }
      expect(subject.to_hash).to eql(hash)
    end
  end
end
