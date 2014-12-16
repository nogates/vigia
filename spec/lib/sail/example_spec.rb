require 'spec_helper'

describe Vigia::Sail::Example do

  let(:options)       { { } }
  let(:rspec_context) { double(described_class: testing_described_class) }
  let(:testing_described_class) { double }

  describe '::example_contexts_include?' do
    let(:context)          { double(options: context_options, name: context_name) }
    let(:example_name)     { :a_random_example }
    let(:enabled_contexts) { nil }
    let(:context_options)  { {} }
    let(:context_name)     { :a_test_context }

    context 'when the context defines an examples option' do
      context 'when the example name is listed in the option' do
        let(:context_options)  { { examples: [ :a_random_example] } }

        it 'returns true' do
          expect(described_class.example_contexts_include?(context, example_name, enabled_contexts))
            .to be true
        end
      end

      context 'when the example name is not listed in the option' do
        let(:context_options)  { { examples: [ :a_not_so_random_example] } }

        it 'returns false' do
          expect(described_class.example_contexts_include?(context, example_name, enabled_contexts))
            .to be false
        end
      end
    end

    context 'when the example specifies the context option' do
      let(:enabled_contexts) { [:a_test_context] }

      context 'when the context name matches' do
        it 'returns true' do
          expect(described_class.example_contexts_include?(context, example_name, enabled_contexts))
            .to be true
        end
      end

      context 'when the context name does not match' do
        let(:enabled_contexts) { [:not_the_test_context] }

        it 'returns false' do
          expect(described_class.example_contexts_include?(context, example_name, enabled_contexts))
            .to be false
        end
      end
    end

    context 'when no options are used' do
      context 'when the context is the default' do
        let(:context_name) { :default }

        it 'returns true' do
          expect(described_class.example_contexts_include?(context, example_name, enabled_contexts))
            .to be true
        end
      end

      context 'when the context is not the default' do
        it 'returns false' do
          expect(described_class.example_contexts_include?(context, example_name, enabled_contexts))
            .to be false
        end
      end
    end
  end

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

  describe '#expectation' do
    let(:options) { { expectation: block } }

    context 'when expectation responds to :call' do
      let(:block)   { -> { 'a block' } }

      it 'returns the block' do
        expect(subject.expectation).to be(block)
      end
    end

    context 'when expectation does not respond to :call' do
      let(:block) { 'a string' }

      it 'raises an exception' do
        expect { subject.expectation }.to raise_error
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
