require 'spec_helper'

describe Vigia::Url do

  include_examples "redsnow doubles"

  let(:parameters) do
    instance_double(
      Vigia::Parameters,
      to_hash: parameters_hash
    )
  end

  let(:parameters_hash) { { 'scenario_slug' => 'scenario_one', 'page' => '3' } }
  let(:uri_template)    { '/scenarios/{scenario_slug}/examples{?page,sort}' }
  let(:host)            { 'http://example.com' }

  subject do
    described_class.new uri_template
  end

  describe '#expand' do
    before do
      allow(subject).to receive(:host).and_return('http://this-example.com')
    end

    it 'returns the right url' do
      expect(subject.expand(parameters)).to eql('http://this-example.com/scenarios/scenario_one/examples?page=3')
    end
  end

  describe '#validate' do
    context 'when url parameter validation is enabled' do
      context 'when url does not have required parameters' do
        let(:parameters_hash) { { 'without_url_parameters' => 'truedat' } }
        let(:uri_template) { '/scenarios/{?without_url_parameters}' }

        it 'does not raise an error' do
          expect { subject.validate(parameters) }.not_to raise_error
        end
      end
      context 'when url parameters are valid' do
        let(:parameters_hash) { { 'scenario_slug' => 'scenario_one' } }

        it 'does not raise an error' do
          expect { subject.validate(parameters) }.not_to raise_error
        end
      end
      context 'when url parameters are invalid' do
        let(:parameters_hash) { { 'scenario_slug' => '', 'page' => '3' } }

        it 'raises an error' do
          expect { subject.validate(parameters) }.to raise_error
        end
      end
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
