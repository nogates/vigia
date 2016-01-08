require 'spec_helper'

describe 'Vigia default examples' do
  before do
    Vigia::Sail::Examples::Default.load!
  end

  let(:expectations) { double }
  let(:result)       { double }

  describe 'code_match' do
    subject do
      Vigia::Sail::Example.collection[:code_match]
    end

    context 'when the code is a range' do
      before do
        allow(expectations).to receive(:code).and_return(200..299)
      end

      context 'when the code is in the range' do
        before do
          allow(result).to receive(:code).and_return(201)
        end

        it 'passes' do
          instance_exec(&subject[:expectation])
        end
      end

      context 'when the code is not in the range' do
        before do
          allow(result).to receive(:code).and_return(300..301)
        end

        it 'fails with the right exception' do
          expect { instance_exec(&subject[:expectation]) }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end
    end
    context 'when the code is not range' do
      before do
        allow(expectations).to receive(:code).and_return(200)
      end

      context 'when the code is the same' do
        before do
          allow(result).to receive(:code).and_return(200)
        end

        it 'passes' do
          instance_exec(&subject[:expectation])
        end
      end

      context 'when the code is not the same' do
        before do
          allow(result).to receive(:code).and_return(201)
        end

        it 'fails with the right exception' do
          expect { instance_exec(&subject[:expectation]) }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end
    end
  end

  describe 'include_headers' do
    subject do
      Vigia::Sail::Example.collection[:include_headers]
    end

    let(:expected_headers) { { a_header: 'its content' } }

    before do
      allow(expectations).to receive(:headers).and_return(expected_headers)
      allow(result).to receive(:headers).and_return(result_headers)
    end

    context 'when the expected headers are included in the result' do
      let(:result_headers) { { a_header: 'its content', another: 'another content' } }

      it 'passes' do
        instance_exec(&subject[:expectation])
      end
    end

   context 'when the expected headers are not included in the result' do
      let(:result_headers) { { another: 'another content' } }

      it 'fails with the right exception' do
        expect { instance_exec(&subject[:expectation]) }
          .to raise_error RSpec::Expectations::ExpectationNotMetError
      end
    end
  end
end
