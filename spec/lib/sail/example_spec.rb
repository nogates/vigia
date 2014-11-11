require 'spec_helper'

describe Vigia::Sail::Example do

  let(:options)       { { } }
  let(:rspec_context) { double(described_class: testing_described_class) }
  let(:testing_described_class) { double }

  subject do
    described_class.new :example_name, options, rspec_context
  end

  describe '#skip?' do
    context 'when the options skip_if does not exist' do

      it 'does not call the contextual_object method' do
        expect(subject).not_to receive(:contextual_object)
        subject.skip?('a')
      end

      it 'returns false' do
        expect(subject.skip?('a')).to be(false)
      end
    end

    context 'when the option skip_if exists' do
      let(:options) { { skip_if: true } }

      it 'calls the contextual object with the right values' do
        expect(subject).to receive(:contextual_object).with(option_name: :skip_if, context: 'a')
        subject.skip?('a')
      end

      it 'returns true' do
        expect(subject.skip?('a')).to be(true)
      end
    end
  end

  describe '#disabled?' do
    context 'when the options disable_if does not exist' do

      it 'does not call the contextual_object method' do
        expect(subject).not_to receive(:contextual_object)
        subject.disabled?('a')
      end

      it 'returns false' do
        expect(subject.disabled?('a')).to be(false)
      end
    end

    context 'when the option disable_if exists' do
      let(:options) { { disable_if: true } }

      it 'calls the contextual object with the right values' do
        expect(subject).to receive(:contextual_object).with(option_name: :disable_if, context: 'a')
        subject.disabled?('a')
      end

      it 'returns true' do
        expect(subject.disabled?('a')).to be(true)
      end
    end
  end

  describe '#to_s' do
    context 'when option description is nil' do

      it 'does not call contextual_object' do
        expect(subject).not_to receive(:contextual_object)
        subject.to_s
      end

      it 'returns the string version of the name' do
        expect(subject.to_s).to eql('example_name')
      end
    end

    context 'when the option description exists' do
      let(:options) { { description: 'a description' } }

      it 'calls the contextual_object method with the right values' do
        expect(subject).to receive(:contextual_object).with(option_name: :description)
        subject.to_s
      end

      it 'returns its content' do
        expect(subject.to_s).to eql('a description')
      end
    end
  end
end
