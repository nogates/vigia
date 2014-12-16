require 'spec_helper'

describe Vigia::Sail::Context do

  let(:options)                 { { } }
  let(:rspec_context)           { double(described_class: testing_described_class) }
  let(:testing_described_class) { double }


  subject do
    described_class.new :example_context, options, rspec_context
  end

  describe '#to_s' do
    context 'when the description option has been defined' do
      let(:options) { { description: 'a context name' } }

      it 'outputs the context name' do
        expect(subject.to_s).to eql('a context name')
      end
    end
    context 'when description option is not defined' do
      it 'outputs the context name' do
        expect(subject.to_s).to eql('context example_context')
      end
    end
  end

  describe '#run' do
    after do
      subject.run
    end

    context 'when disabled' do
      let(:options) { { disable_if: true } }

      it 'does not call run_rspec_context' do
        expect(subject).not_to receive(:run_rspec_context)
      end
    end
    context 'when not disabled' do
      let(:options) { { disable_if: false } }

      it 'does call run_rspec_context' do
        expect(subject).to receive(:run_rspec_context)
      end
    end
  end

  describe '#run_children' do
    let(:context_collection) { {} }
    let(:rspec_context)      { 'rspec_context' }

    before do
      allow(described_class).to receive(:collection).and_return(context_collection)
    end

    after do
      subject.run_children(rspec_context)
    end

    context 'when the current context defines children' do
      let(:options)  { { contexts: :a_context } }

      it 'runs the context' do
        expect(Vigia::Sail::Context).to receive(:setup_and_run).with(:a_context, rspec_context)
      end
    end

    context 'when another context should be executed in this context' do
      let(:context_collection) { {another_context: { in_contexts: [:example_context] } } }

      it 'runs the context' do
        expect(Vigia::Sail::Context).to receive(:setup_and_run).with(:another_context, rspec_context)
      end
    end
  end

  describe '#run_shared_examples' do
    let(:config) do
      instance_double(Vigia::Config, custom_examples: custom_examples)
    end
    let(:in_context) { double }

    before do
      allow(Vigia).to receive(:config).and_return(config)
    end

    context 'when context has custom examples' do
      let(:custom_examples) do
        [ { name: 'test', filter: :all },
          { name: 'tezt', filter: :no_here } ]
      end

      after do
        subject.run_shared_examples(in_context)
      end

      it 'uses a default filter' do
        expect(in_context).to receive(:include_examples).with('test')
      end

      it 'does not includes a invalid context' do
        expect(in_context).not_to receive(:include_examples).with('tezt')
      end
    end
  end
end
