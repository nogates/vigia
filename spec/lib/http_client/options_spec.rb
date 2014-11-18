require 'spec_helper'

describe Vigia::HttpClient::Options do
  let(:config) do
    instance_double(
      Vigia::Config,
      headers: config_headers
    )
  end
  let(:context) do
    instance_double(
      Vigia::Sail::Context
    )
  end
  let(:let_context) { double }
  let(:headers)     { {} }

  before do
    allow(Vigia).to receive(:config).and_return(config)
  end

  describe '#include_config_headers!' do
    let(:config_headers)   { { test_header: 'a test' } }
    let(:adapter_headers)  { { a_header: 'adapter header' } }

    before do
      subject.headers = adapter_headers
    end

    it 'calls config headers' do
      expect(config).to receive(:headers)
      subject.include_config_headers
    end

    it 'merges the config headers with the adapter headers' do
      expect(subject.include_config_headers).to eql(adapter_headers.merge(config_headers))
    end
  end
end
