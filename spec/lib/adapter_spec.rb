require 'spec_helper'

describe Vigia::Adapter do
  let(:config) do
    instance_double(
      Vigia::Config,
      source_file: source_file
    )
  end
  let(:source_file) { 'a file' }
  let(:template)    { -> { 'a template proc' } }

  before do
    allow(Vigia).to receive(:config).and_return(config)
    allow(described_class).to receive(:new).and_return(subject)
    described_class.instance_variable_set('@template', template)
  end

  describe '::setup_adapter' do
    let(:template) { -> { 'a proc' } }

    it 'raises an exception if not block has given' do
      expect { described_class.setup_adapter }.to raise_error RuntimeError
    end

    it 'stores the block in the @template variable' do
      described_class.setup_adapter(&template)
      expect(described_class.instance_variable_get('@template')).to be(template)
    end
  end

  describe '::instance' do
    let(:source_file) { 'a file' }
    let(:structure) do
      instance_double(
        Vigia::Adapter::Structure,
        preload: nil
      )
    end

    before do
      allow(Vigia::Adapter::Structure).to receive(:new).and_return(structure)
    end

    after do
      described_class.instance
    end

    it 'creates a new object' do
      expect(described_class).to receive(:new)
    end

    it 'sets the source file on the instance' do
      expect(subject).to receive(:source_file=).with(source_file)
    end

    it 'creates a new structure object' do
      expect(Vigia::Adapter::Structure).to receive(:new).with(subject, template)
    end

    it 'sets the structure' do
      expect(subject).to receive(:structure=).with(structure)
    end

    it 'returns the instance' do
      expect(described_class.instance).to be(subject)
    end
  end
end

describe Vigia::Adapter::Structure do
  let(:adapter)  { double }
  let(:template) { -> { 'a proc' } }

  subject do
    described_class.new(adapter, template)
  end

  describe '::generate' do
    before do
      allow(described_class).to receive(:new).and_return(subject)
    end

    after do
      described_class.generate(adapter, template)
    end

    it 'creates a new instance' do
      expect(described_class).to receive(:new).with(adapter, template)
    end

    it 'preloads the template' do
      expect(subject).to receive(:preload)
    end

    it 'returns the instance' do
      expect(described_class.generate(adapter, template)).to be(subject)
    end
  end

  describe '#initialize' do
    it 'creates a reader for the adapter' do
      expect(subject.adapter).to be(adapter)
    end
    it 'creates a reader for the template' do
      expect(subject.template).to be(template)
    end
    it 'creates a reader for the grops' do
      expect(subject.groups).to eql({})
    end
    it 'creates a reader for the contexts' do
      expect(subject.contexts).to eql({})
    end
  end

  describe '#preload' do
    after do
      subject.preload
    end

    it 'execs the template on the instance' do
      expect(subject).to receive(:instance_exec) # and yield
    end

    it 'sets the vigia sail groups ' do
      Vigia::Sail::Group.collection
    end

  end
end
