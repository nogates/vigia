require 'spec_helper'

class Hookeable
  include Vigia::Hooks
end

describe Hookeable do
  let(:config) do
    instance_double(
      Vigia::Config,
      hooks: config_hooks
    )
  end

  before do
    allow(subject).to receive(:options).and_return(options)
    allow(Vigia).to receive(:config).and_return(config)
  end

  context 'object hooks' do
    let(:options)        { { before_hookeable: 'hook in options' } }
    let(:config_hooks)   { [] }

    it 'returns the hook in options' do
      expect(subject.hooks_for_object(:before)).to include 'hook in options'
    end
  end

  context 'config hooks' do
    let(:options)        { {} }
    let(:config_hooks)   { [{ rspec_class: Hookeable, filter: :before, block: 'hook in config' }] }

    it 'returns the hook in config' do
      expect(subject.hooks_for_object(:before)).to include 'hook in config'
    end
  end
end
