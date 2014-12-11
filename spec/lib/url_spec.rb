require 'spec_helper'

describe Vigia::Url do

  include_examples "redsnow doubles"

  let(:parameters) do
    instance_double(
      Vigia::Parameters,
      to_hash: parameters_hash
    )
  end

  let(:parameters_hash) do
    [
      { name: 'scenario_slug', value: 'scenario_one', required: true },
      { name: 'page', value: '3', required: false }
    ]
  end

  let(:uri_template)    { '/scenarios/{scenario_slug}/examples{?page,sort}' }
  let(:host)            { 'http://example.com' }

  subject do
    described_class.new uri_template
  end

  describe '::template_defines_url?' do
    it 'returns true if the url matches the template' do
      expect(described_class.template_defines_url?('/a_resource/{id}', '/a_resource/test')).to be true
    end

    it 'returns false if the url does not match the template' do
      expect(described_class.template_defines_url?('/a_resource/{id}', '/a_resourcetest')).to be false
    end
  end

  describe '#expand' do
    before do
      allow(subject).to receive(:host).and_return('http://this-example.com')
    end

    it 'returns the right url' do
      expect(subject.expand(parameters_hash)).to eql('http://this-example.com/scenarios/scenario_one/examples?page=3')
    end
  end

  describe '#host' do
    let(:config) { instance_double(Vigia::Config, host: 'the_host') }

    before do
      allow(Vigia).to receive(:config).and_return(config)
    end

    it 'calls the Vigia.config.host to get the host value' do
      subject.host
      expect(Vigia).to have_received(:config)
    end

    it 'returns the proper value' do
      expect(subject.host).to eql('the_host')
    end
  end
end
