require 'spec_helper'

describe Vigia::Sail::Context do

  let(:options)                 { { } }
  let(:rspec_context)           { double(described_class: testing_described_class) }
  let(:testing_described_class) { double }


  subject do
    described_class.new :example_name, options, rspec_context
  end

  describe '#to_s' do
    it 'outputs the context name' do
      expect(subject.to_s).to eql('context example_name')
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
