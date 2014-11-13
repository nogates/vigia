require 'spec_helper'

describe Vigia::Sail::RSpecObject do

  let(:options)                 { double(:'[]' => nil) }
  let(:rspec_context)           { double(described_class: testing_described_class) }
  let(:testing_described_class) { double }

  subject do
    described_class.new :name, options, rspec_context
  end

  describe '#contextual_object' do
    let(:option_name) { nil }
    let(:object)      { nil }
    let(:context)     { nil }

    after do
      subject.contextual_object(option_name: option_name, object: object, context: context)
    end

    context 'when context is passed' do
      let(:context) { rspec_context }

      context 'when is a proc' do
        let(:object)  { -> { 'a proc' } }

        it 'executes the proc inside that context' do
          expect(rspec_context).to receive(:instance_exec)
        end
      end
      context 'when is a symbol' do
        let(:object) { :class }

        it 'calls the symbol as a method on the adapter' do
          expect(rspec_context).to receive(:adapter)
        end
      end
    end

    context 'when context is nil' do
      context 'when is a proc' do
        let(:object)  { -> { 'a proc' } }

        it 'executes the proc inside the rspec described_class' do
          expect(testing_described_class).to receive(:instance_exec)
        end
      end
      context 'when is a symbol' do
        let(:object) { :class }

        it 'calls the symbol as a method on the adapter' do
          expect(testing_described_class).to receive(:adapter)
        end
      end
    end
  end
end
