require 'spec_helper'

describe Vigia::Adapters::Blueprint do

  include_examples "redsnow doubles"

  describe '#payload_for' do
    context 'when the payload exists' do
      let(:payload_body) { 'The body' }
      it 'returns the payload' do
        expect(subject.payload_for(apib_example, response))
          .to eql('The body')
      end
    end

    context 'when the payload does not exist' do
      let(:other_response) do
        instance_double(
          RedSnow::Payload,
          name:    'A different response'
        )
      end
      it 'raises an error' do
        expect { subject.payload_for(apib_example, other_response) }
          .to raise_error('Unable to load payload for response A different response')
      end
    end
  end
end
