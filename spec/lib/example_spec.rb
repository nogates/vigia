require 'spec_helper'

describe SpecApib::Example do
  
  include_examples "redsnow doubles" 
  
  let(:uri_template)          { instance_double(SpecApib::Url, to_s: '') }
  let(:resource_uri_template) { '/scenarios/default' }
  let(:http_client_result) { {code: 200, headers: {}, body: 'the body' } }
  
  subject do
    allow(SpecApib::Url).to receive(:new).and_return(uri_template)
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
      uri_template_options = {
        uri_template: resource_uri_template,
        parameters: [resource_parameter_one, action_parameter_one]
      }
      expect(SpecApib::Url).to receive(:new)
        .with(uri_template_options).once
      subject
    end
  end

  describe '#perform_request' do
    let(:response) { instance_double(RedSnow::Payload, name: 'specapib') }
    let(:requests) { {} }

    before do
      allow(subject).to receive(:http_options_for).and_return({options: {}})
      allow(subject).to receive(:http_client_request).and_return(http_client_result)
    end

    context 'when the request has not been performed yet' do
      before do
        subject.instance_variable_set("@requests", {})
        subject.perform_request(response)
      end

      it 'generates the options for the http client' do
        expect(subject).to have_received(:http_options_for).with(response)
      end

      it 'calls the http_client on the runner' do
        expect(subject).to have_received(:http_client_request).with({options: {}})
      end

      it 'includes the request in the requests hash' do
        expect(subject.requests['specapib']).to eql(http_client_result)
      end
    end

    context 'when the request has been performed yet' do
      before do
        subject.instance_variable_set("@requests", { 'specapib' => 'the cached response' })
        subject.perform_request(response)
      end

      it 'does not generates the options for the http client' do
        expect(subject).not_to have_received(:http_options_for)
      end

      it 'does not call the http_client on the runner' do
        expect(subject).not_to have_received(:http_client_request)
      end

      it 'includes the request in the requests hash' do
        expect(subject.requests['specapib']).to eql('the cached response')
      end
    end
  end
  
  describe '#expectations_for' do
    let(:expectations) { subject.expectations_for(response) }
    let(:expected_response_name) { '200' }
    let(:expected_response_body) { 'The expected body' }

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
  
  describe '#compile_url' do
    it 'calls to_s on uri_template' do
      subject.compile_url
      expect(uri_template).to have_received(:to_s)
    end
  end
end
