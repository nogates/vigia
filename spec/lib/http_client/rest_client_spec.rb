require 'spec_helper'

describe Vigia::HttpClient::RestClient do
  let(:http_options) { {} }

  subject do
    described_class.new(http_options)
  end

  describe '#run!' do
    it 'calls #perform_request' do
      allow(subject).to receive(:perform_request)
      subject.run!
    end
  end
end
