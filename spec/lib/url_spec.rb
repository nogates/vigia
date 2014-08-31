require 'spec_helper'

describe SpecApib::Url do

  include_examples "redsnow doubles"

  let(:uri_template) { '/scenarios/{scenario_slug}/examples/{?page,sort}' }
  let(:parameters)   { resource_parameters.collection + action_parameters.collection }
  let(:host)         { 'http://example.com' }

  subject do
    described_class.new(
      uri_template: uri_template,
      parameters: parameters
    )
  end

  describe '#to_s' do
    before do
      allow(subject).to receive(:modify_url_parameters).and_return('/scenarios/scenario_one/{?page,sort}')
      allow(subject).to receive(:modify_query_parameters).and_return('/scenarios/scenario_one/?page=2')
      allow(subject).to receive(:host).and_return('http://this_example.com')
    end

    it 'returns the right url' do
      expect(subject.to_s).to eql('http://this_example.com/scenarios/scenario_one/?page=2')
    end
  end

  describe '#host' do
    let(:config) { instance_double(SpecApib::Config, host: 'the_host') }

    before do
      allow(SpecApib).to receive(:config).and_return(config)
    end

    it 'calls the SpecApib.config.host to get the host value' do
      subject.host
      expect(SpecApib).to have_received(:config)
    end

    it 'returns the proper value' do
      expect(subject.host).to eql('the_host')
    end
  end

  describe '#modify_url_parameters' do
    let(:modify_url_parameters) { subject.modify_url_parameters(uri_template) }

    context 'when uri_template has 0 url parameters' do
      let(:uri_template) { '/scenarios/one' }

      it 'returns the same url' do
        expect(modify_url_parameters).to eql(uri_template)
      end
    end
    context 'when uri_template has 1 url parameters' do
      let(:uri_template) { '/scenarios/{scenario_slug}' }

      it 'modifies the url parameter' do
        expect(modify_url_parameters).to eql('/scenarios/scenario_one')
      end
    end

    context 'when uri_template has 2 url parameters' do
      let(:uri_template) { '/scenarios/{scenario_slug,page}' }

      it 'modifies the url parameter and includes both parameters' do
        expect(modify_url_parameters).to eql('/scenarios/scenario_one/3')
      end
    end

    context 'when uri template has 2 url group parameters' do
      let(:uri_template) { '/scenarios/{scenario_slug}/pages/{page}' }

      it 'modifies both groups and includes both parameters' do
        expect(modify_url_parameters).to eql('/scenarios/scenario_one/pages/3')
      end
    end

    context 'when uri_template has query parameters' do
      let(:uri_template) { '/scenarios/{?page}' }

      it 'does not modify the url' do
        expect(modify_url_parameters).to eql('/scenarios/{?page}')
      end
    end
  end

  describe '#modify_query_parameters' do
    let(:modify_query_parameters) { subject.modify_query_parameters(uri_template) }

    context 'when uri_template has 0 query parameters' do
      let(:uri_template) { '/scenarios/one' }

      it 'returns the same url' do
        expect(modify_query_parameters).to eql(uri_template)
      end
    end
    context 'when uri_template has 1 query parameters' do
      let(:uri_template) { '/scenarios/{?scenario_slug}' }

      it 'modifies the query parameter' do
        expect(modify_query_parameters).to eql('/scenarios/?scenario_slug=scenario_one')
      end
    end

    context 'when uri_template has 2 query parameters' do
      let(:uri_template) { '/scenarios/{?scenario_slug,page}' }

      it 'modifies the url parameter and includes both parameters' do
        expect(modify_query_parameters).to eql('/scenarios/?scenario_slug=scenario_one&page=3')
      end
    end
    context 'when uri_template has url parameters' do
      let(:uri_template) { '/scenarios/{page}' }

      it 'does not modify the url' do
        expect(modify_query_parameters).to eql('/scenarios/{page}')
      end
    end
  end
end
