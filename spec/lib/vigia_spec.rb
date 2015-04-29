require 'spec_helper'

describe Vigia do

  describe '::rspec!' do
    let(:rspec) do
      instance_double(Vigia::Rspec, run!: nil)
    end

    let(:config) do
      instance_double(Vigia::Config, validate!: true)
    end

    before do
      allow(Vigia::Rspec).to receive(:new).and_return(rspec)
      allow(Vigia).to receive(:config).and_return(config)
    end

    context 'when config is nil' do
      let(:config) { nil }

      it 'raises an exception' do
        expect { described_class.rspec! }.to raise_error
      end
    end

    context 'when config is invalid' do
      before do
        allow(config).to receive(:validate!).and_return(false)
      end

      it 'raises an exception' do
        expect { described_class.rspec! }.to raise_error
      end
    end

    context 'when config exists and is valid' do
      before do
        allow(config).to receive(:host).and_return('http://example.com')
      end

      it 'creates a new Vigia::Rspec instance and runs it' do
        expect(rspec).to receive(:run!)
        described_class.rspec!
      end
    end
  end

  describe '::configure' do

    before do
      Vigia.configure(&config_block)
    end

    let(:config_block) do
      lambda { |config| }
    end

    context  'when the configuration blocks sets load_default_examples to false' do
      let(:config_block) do
        lambda do |config|
          config.load_default_examples = false
        end
      end

      it 'does not load the default examples' do
        expect(Vigia::Sail::Example.collection).to be_empty
      end
    end

    context 'when the configuration block does not change the load_default_examples' do
      it 'Example collection has the default examples' do
        expect(Vigia::Sail::Example.collection.keys).to eql [ :code_match, :include_headers ]
      end
    end
  end

  describe '::reset!' do

    before do
      Vigia.instance_variable_set('@config', 'some config')
      [ Vigia::Sail::Group, Vigia::Sail::Example, Vigia::Sail::Context ].map do |klass|
        klass.register('a name', some: 'option')
      end
    end

    context 'after resetting' do
      before do
        Vigia.reset!
      end

      it 'should clean config' do
        expect(Vigia.config).to be_nil
      end

      it 'removes all the registered groups' do
        expect(Vigia::Sail::Group.collection).to be_empty
      end

      it 'removes all the registered contexts' do
        expect(Vigia::Sail::Context.collection).to be_empty
      end

      it 'removes all the registered examples' do
        expect(Vigia::Sail::Example.collection.keys).to be_empty
      end
    end
  end
end
