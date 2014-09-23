require 'spec_helper'

describe Vigia::Example do

  include_examples "redsnow doubles"

  let(:url)                   { instance_double(Vigia::Url, expand: '') }
  let(:parameters)            { instance_double(Vigia::Parameters, to_hash: parameters_hash) }
  let(:parameters_hash)       { { } }
  let(:resource_uri_template) { '/scenarios/default' }
  let(:http_client_result)    { { code: 200, headers: {}, body: 'the body' } }

  subject do
    allow(Vigia::Url).to receive(:new).and_return(url)
    allow(Vigia::Parameters).to receive(:new).and_return(parameters)
    described_class.new(
      resource: resource,
      action: action,
      apib_example: apib_example
    )
  end

  describe '#initialize' do
    it '#attr_reader :resource' do
      expect(subject.resource).to be(resource)
    end
    it '#attr_reader :action' do
      expect(subject.action).to be(action)
    end
    it '#attr_reader :apib_example' do
      expect(subject.apib_example).to be(apib_example)
    end
    it '#attr_reader :requests' do
      expect(subject.requests).to eql({})
    end
    it 'creates a new UriTemplates object' do
      expect(Vigia::Url).to receive(:new)
        .with(resource_uri_template).once
      subject
    end
  end

  describe '#perform_request' do
    let(:vigia_config) do
      instance_double(
        Vigia::Config,
        http_client_class: Object,
        headers: config_header
      )
    end

    let(:response_name) { 'vigia' }
    let(:action_method) { 'DELETE' }
    let(:url)           { 'http://therequest.com/scenario_one' }
    let(:config_header) { { config_header: 'a config header' } }
    let(:http_options)  { { method: action_method, headers: headers, url: url } }
    let(:requests)      { {} }
    let(:resource_model_headers_collection) do
      [ { name: 'Content-type', value: 'application/json' } ]
    end
    let(:response_headers_collection) do
      [ { name: 'My-Custom-Header', value: 'your value here' } ]
    end

    let(:headers) do
      {
        config_header: 'a config header',
        content_type: 'application/json',
        my_custom_header: 'your value here'
      }
    end

    before do
      allow(Vigia).to   receive(:config).and_return(vigia_config)
      allow(subject).to receive(:http_options_for).and_call_original
      allow(subject).to receive(:http_client_request).and_return(http_client_result)
      allow(subject).to receive(:url).and_return(url)
    end

    context 'when the request has not been performed yet' do
      before do |example|
        subject.instance_variable_set("@requests", requests)
        subject.perform_request(response) unless example.metadata[:skip_perfom_request]
      end

      it 'generates the options for the http client' do
        expect(subject).to have_received(:http_options_for).with(response)
      end

      it 'calls the http_client on the runner with the correct http_options' do
        expect(subject).to have_received(:http_client_request).with(http_options)
      end

      it 'includes the request in the requests hash' do
        expect(subject.requests['vigia']).to eql(http_client_result)
      end

      context 'when the request includes payload' do
        let(:action_method) { 'POST' }
        let(:payload_body)  { 'This request content' }
        let(:http_options)  do
          {
            method: action_method,
            headers: headers,
            url: url,
            payload: payload_body }
        end

        let(:payload_headers_collection) do
          [ { name: 'Content-type', value: 'application/special-json' },
            { name: 'Another-fancy-header', value: 'lorem ipsum' } ]
        end
        let(:headers) do
          {
            config_header: 'a config header',
            content_type: 'application/special-json',
            my_custom_header: 'your value here',
            another_fancy_header: 'lorem ipsum'
          }
        end
        context 'when the payload exists' do
          it 'calls the http_client on the runner with the correct http_options' do
            expect(subject).to have_received(:http_client_request).with(http_options)
          end
        end

        context 'when the payload does not exists', skip_perfom_request: true do
          let(:apib_example) do
            instance_double(RedSnow::TransactionExample, requests: [], responses: [ response ])
          end
          it 'raises an error' do
            expect { subject.perform_request(response) }.to raise_error
          end
        end
      end
    end

    context 'when the request has been performed yet' do
      before do
        subject.instance_variable_set("@requests", { 'vigia' => 'the cached response' })
        subject.perform_request(response)
      end

      it 'does not generates the options for the http client' do
        expect(subject).not_to have_received(:http_options_for)
      end

#       it 'does not call the http_client on the runner' do
#         expect(subject).not_to have_received(:http_client_request)
#       end

      it 'includes the request in the requests hash' do
        expect(subject.requests['vigia']).to eql('the cached response')
      end
    end
  end

  describe '#expectations_for' do
    let(:expectations) { subject.expectations_for(response) }
    let(:response_name) { '200' }
    let(:response_body) { 'The expected body' }

    let(:resource_model_headers_collection) do
      [ {name: 'Resource Header', value: 'Resource Value' } ]
    end
    let(:response_headers_collection) do
      [ {name: 'Response Header', value: 'Response Value' } ]
    end

    it 'includes the expected code' do
      expect(expectations[:code]).to be(200)
    end

    it 'includes the expected headers' do
      headers = {
        :'resource header' => 'Resource Value',
        :'response header' => 'Response Value'
      }
      expect(expectations[:headers]).to eql(headers)
    end

    it 'includes the expected body' do
      expect(expectations[:body]).to eql('The expected body')
    end
  end

  describe '#url' do
    let(:parameters_hash) { { paramter_one: 'a', paramter_two: 'b' } }
    it 'calls expand on uri_template with parameters' do
      expect(url).to receive(:expand).with(parameters_hash)
      subject.url
    end
  end

  describe '#skip?' do
    context 'when resource description includes @skip' do
      let(:resource_description) { 'Skip this resource @skip' }
      it 'returns true' do
        expect(subject.skip?).to be_truthy
      end
    end

    context 'when action description includes @skip' do
      let(:action_description) { 'Skip this action @skip' }
      it 'returns true' do
        expect(subject.skip?).to be_truthy
      end
    end

    context 'when action and resource description do not include @skip' do
      let(:resource_description) { 'Do not skip this resource' }
      let(:resource_description) { 'Do not skip this resource' }
      it 'returns false' do
        expect(subject.skip?).to be_falsy
      end
    end
  end
end
