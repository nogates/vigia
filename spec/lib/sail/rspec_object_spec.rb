require 'spec_helper'

describe Vigia::Sail::RSpecObject do

  let(:options)                 { double(:'[]' => nil) }
  let(:rspec_context)           { double(described_class: testing_described_class) }
  let(:testing_described_class) { double }

  subject do
    described_class.new :name, options, rspec_context
  end

  describe '::setup_and_run' do
    let(:collection) { [] }

    before do
      allow(described_class).to receive(:collection).and_return(collection)
    end

    context 'when the item cannot be found' do
      it 'raises an exception' do
        expect { described_class.setup_and_run(:not_here, rspec_context) }
          .to raise_error('Cannot find Vigia::Sail::RSpecObject with name not_here')
      end
    end
    context 'when the item is found' do
      let(:instance)    { double(run: nil) }
      let(:collection)  { { a_rspec_object: { the_options: 1 } } }

      before do
        allow(described_class).to receive(:new)
          .with(:a_rspec_object, { the_options: 1 }, rspec_context).and_return(instance)
      end

      after do
        described_class.setup_and_run(:a_rspec_object, rspec_context)
      end

      it 'creates the instance' do
        expect(described_class).to receive(:new)
          .with(:a_rspec_object, { the_options: 1 }, rspec_context)
      end

      it 'calls run on the instance' do
        expect(instance).to receive(:run)
      end
    end
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
