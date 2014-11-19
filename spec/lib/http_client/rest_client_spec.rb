require 'spec_helper'

describe Vigia::HttpClient::RestClient do
  let(:http_options) { {} }

  subject do
    described_class.new(http_options)
  end

  describe '#run!' do
    let(:http_options) { { http_options: 'the options' } }

    it 'calls #perform_request' do
      expect(subject).to receive(:perform_request)
      subject.run!
    end

    describe 'parsing RestClient response' do
      let(:request) do
        double(
          code:    'code',
          headers: 'headers',
          body:    'body'
          )
      end

      before do
        allow(subject).to receive(:perform_request).and_call_original
        allow(RestClient::Request).to receive(:execute).with(http_options).and_return(request)
      end

      it 'calls RestClient execute' do
        expect(RestClient::Request).to receive(:execute).with(http_options.to_h)
        subject.run!
      end

      context 'when RestClient works normally' do
        it 'creates a new Vigia::HttpClient::ClientRequest with the the request params' do
          expect(Vigia::HttpClient::ClientRequest).to receive(:new)
            .with(code: 'code', headers: 'headers', body: 'body')
          subject.run!
        end
      end
      context 'when RestClient raises an exception normally' do
        let(:response) do
          double(
            headers: 'exception headers',
          )
        end
        let(:exception) do
          ex = RestClient::Exception.new
          allow(ex).to receive(:http_code).and_return('exception code')
          allow(ex).to receive(:response).and_return(response)
          allow(ex).to receive(:http_body).and_return('exception body')
          ex
        end

        before do
          allow(RestClient::Request).to receive(:execute).with(http_options).and_raise(exception)
        end

        it 'creates a new Vigia::HttpClient::ClientRequest with the exception params' do
          expect(Vigia::HttpClient::ClientRequest).to receive(:new)
            .with(code: 'exception code', headers: 'exception headers', body: 'exception body')
          subject.run!
        end
      end
    end
  end

  describe '#run' do
    it 'calls #cache_or_perform_request' do
      expect(subject).to receive(:cache_or_perform_request)
      subject.run
    end
  end
end
