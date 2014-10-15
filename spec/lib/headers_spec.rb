require 'spec_helper'

describe Vigia::Headers do

  include_examples "redsnow doubles"

  let(:resource_model_headers_collection) do
    [ {name: 'Resource-Model-Header-One', value: 'Resource Model One Value' } ]
  end

  let(:response_headers_collection) do
    [ {name: 'Response-Header-One', value: 'Response One Value' } ]
  end

  let(:config_headers) { { default: 'nah' } }

  let(:config) { instance_double(Vigia::Config, headers: config_headers) }

  subject do
    described_class.new resource
  end

  before do
    allow(Vigia).to receive(:config).and_return(config)
  end

  describe '#initialize' do
    it 'creates a new Vigia::Headers instance' do
      expect(subject).to be_a(Vigia::Headers)
    end
  end

  describe '#expected' do
    it 'returns the expected headers' do
      expected_headers = {
        :resource_model_header_one => 'Resource Model One Value',
        :response_header_one => 'Response One Value',
      }
      expect(subject.expected(response)).to eql(expected_headers)
    end
  end

  describe '#http_client' do
    let(:config_headers) { { 'Authorization code' => 'the_super_secret_code' } }
    it 'returns the expected headers' do
      expected_headers= {
        :resource_model_header_one => 'Resource Model One Value',
        :response_header_one => 'Response One Value',
        'Authorization code' => 'the_super_secret_code'
      }
      expect(subject.http_client(response)).to eql(expected_headers)
    end
  end

  describe '#http_client_with_payload' do

    let(:payload_headers_collection) do
      [ {name: 'Payload-Header-One', value: 'Payload One Value' } ]
    end

    let(:config_headers) { { 'Authorization code' => 'the_super_secret_code' } }

    it 'returns the expected headers' do
      expected_headers= {
        :resource_model_header_one => 'Resource Model One Value',
        :response_header_one => 'Response One Value',
        :payload_header_one => 'Payload One Value',
        'Authorization code' => 'the_super_secret_code'
      }
      expect(subject.http_client_with_payload(response, payload)).to eql(expected_headers)
    end
  end
end
