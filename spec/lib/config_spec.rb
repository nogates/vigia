require 'spec_helper'

describe Vigia::Config do

  include_examples "redsnow doubles"

  describe '::initialize' do
    context 'when accessing properties' do
      it 'has an apib_path getter with default value' do
        expect(subject.apib_path).to be(nil)
      end
      it 'has a custom_examples_paths getter with default value' do
        expect(subject.custom_examples_paths).to eql([])
      end
      it 'has a custom_examples getter with default value' do
        expect(subject.custom_examples).to eql([])
      end
      it 'has a headers getter with default value' do
        expect(subject.headers).to eql({})
      end
      it 'has a custom_examples_paths getter with default value' do
        expect(subject.custom_examples_paths).to eql([])
      end
      it 'has a http_client_class getter with default value' do
        expect(subject.http_client_class).to eql(Vigia::HttpClient::RestClient)
      end
    end
  end

  describe 'validate!' do
    context 'validating apib_path' do
      before do
        allow(subject).to receive(:host).and_return('exists')
      end

      context 'when @apib_path is empty' do
        it 'raises an error' do
          expect { subject.validate! }.to raise_error
        end
      end
      context 'when @apib_path is not empty' do
        it 'does not raise an error' do
          subject.apib_path = 'a_path'
          expect { subject.validate! }.not_to raise_error
        end
      end
    end
    context 'validating host' do
      before do
        allow(subject).to receive(:host).and_return(host)
        subject.apib_path = 'a_path'
      end

      context 'when host is nil' do
        let(:host) { nil }
        it 'raises an exception' do
          expect{ subject.validate! }.to raise_error
        end
      end
      context 'when host exists' do
        let(:host) { 'a host' }
        it 'raises an exception' do
          expect{ subject.validate! }.not_to raise_error
        end
      end
    end
  end

  describe '#host' do
    let(:blueprint_host) { 'a blueprint host' }
    let(:blueprint_metadata) { instance_double(RedSnow::Metadata, '[]' => blueprint_host) }
    let(:blueprint) { instance_double(Vigia::Blueprint, metadata: blueprint_metadata) }

    before do
      allow(subject).to receive(:blueprint).and_return(blueprint)
      subject.host = host_value
      subject.host
    end

    context 'when @host is not empty' do
      let(:host_value) { 'a @ host' }
      it 'uses @host value' do
        expect(subject).not_to have_received(:blueprint)
      end
      it 'returns the proper value' do
        expect(subject.host).to eql(host_value)
      end
    end
    context 'when @host is empty' do
      let(:host_value) { nil }
      it 'uses blueprint host' do
        expect(subject).to have_received(:blueprint)
      end
      it 'uses the blueprint metadata method' do
        expect(blueprint).to have_received(:metadata)
      end
      it 'returns the proper value' do
        expect(subject.host).to eql('a blueprint host')
      end
    end
  end

  describe '#add_custom_examples_on' do
    before do
      subject.add_custom_examples_on :all, 'the shared examples'
    end

    it 'stores a custom_example reference into @custom_examples' do
      expect(subject.custom_examples).to include(filter: :all, name: 'the shared examples')
    end
  end

  describe '#custom_examples_for' do
    let(:vigia_example) do
      instance_double(
        Vigia::Example,
        resource: resource,
        action: action
      )
    end
    let(:custom_examples) { [] }

    before do
      allow(subject).to receive(:custom_examples).and_return(custom_examples)
    end

    context 'when the custom example filter is :all' do
      let(:custom_examples) { [ { filter: :all, name: 'include me please' } ] }

      it 'includes the example in the response no matter what' do
         expect(subject.custom_examples_for(vigia_example)).to include('include me please')
      end
    end
    context 'when the custom example filter matchs the the action name' do
      let(:custom_examples) { [ { filter: 'Name the action', name: 'included by action name' } ] }
      let(:action_name)     { 'Name the action' }

      it 'includes the example in the response' do
         expect(subject.custom_examples_for(vigia_example)).to include('included by action name')
      end
    end
    context 'when the custom example filter matchs the resource name' do
      let(:custom_examples) { [ { filter: 'Name the resource', name: 'included by resource name' } ] }
      let(:resource_name)   { 'Name the resource' }

      it 'includes the example in the response' do
         expect(subject.custom_examples_for(vigia_example)).to include('included by resource name')
      end
    end
    context 'when the filter does not match the action or the resource name and it is not :all' do
      let(:custom_examples) { [ { filter: 'Impossible filter', name: 'not to be included' } ] }

      it 'includes the example in the response' do
         expect(subject.custom_examples_for(vigia_example)).not_to include('not to be included')
      end
    end

    context 'when mixing several cases' do
      let(:custom_examples) do
        [
          { filter: :all,          name: 'i am in' },
          { filter: 'aaaaaction',  name: 'm2' },
          { filter: 'resssourrce', name: 'and me!!' },
          { filter: 'ooopppsss',   name: 'I shouldnt' }
        ]
      end
      let(:action_name)     { 'aaaaaction' }
      let(:resource_name)   { 'resssourrce' }

      it 'includes the right examples in the response' do
        expect(subject.custom_examples_for(vigia_example)).to contain_exactly('i am in', 'm2', 'and me!!')
      end
    end
  end

  describe '#blueprint' do
    let(:blueprint) { instance_double(Vigia::Blueprint) }
    let(:blueprint_source) { 'the blueprint source' }

    before do
      allow(File).to receive(:read).and_return(blueprint_source)
      allow(Vigia::Blueprint).to receive(:new).and_return(blueprint)
    end

    context 'when its being called for the first time' do
      before do
        subject.blueprint
      end

      it 'generates a new Vigia::Blueprint instance' do
        expect(Vigia::Blueprint).to have_received(:new).with(blueprint_source).once
      end
    end

    context 'when its being called more than once' do
      before do
        subject.blueprint
        subject.blueprint
      end

      it 'returns the Vigia::Blueprint instance' do
        expect(Vigia::Blueprint).to have_received(:new).with(blueprint_source).once
      end
    end
  end
end
