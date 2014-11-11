require 'spec_helper'

describe Vigia::Config do

  include_examples "redsnow doubles"

  describe '::initialize' do
    context 'when accessing properties' do
      it 'has an source_file getter with default value' do
        expect(subject.source_file).to be(nil)
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
    context 'validating source_path' do
      before do
        allow(subject).to receive(:host).and_return('exists')
      end

      context 'when @source_file is empty' do
        it 'raises an error' do
          expect { subject.validate! }.to raise_error
        end
      end
      context 'when @source_file is not empty' do
        it 'does not raise an error' do
          subject.source_file = 'a_path'
          expect { subject.validate! }.not_to raise_error
        end
      end
    end
    context 'validating host' do
      before do
        allow(subject).to receive(:host).and_return(host)
        subject.source_file = 'a_path'
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

  shared_examples_for 'has hooks for' do |rspec_object_name, klass|
    context "#{ rspec_object_name }" do
      let(:block) { -> { 'a block' } }

      after do
        subject.send("#{ filter }_#{ rspec_object_name }", &block)
      end

      [ :after, :before ].each do |filter|
        context "when calling #{ filter }_#{ rspec_object_name }" do
          let(:filter) { 'before' }
          it 'calls the store hook method with the right parameters' do
            expect(subject).to receive(:store_hook).with(klass, :before, block).and_call_original
          end
        end
      end
    end
  end

  it_behaves_like 'has hooks for', :context, Vigia::Sail::Context
  it_behaves_like 'has hooks for', :group, Vigia::Sail::Group
  it_behaves_like 'has hooks for', :example, Vigia::Sail::Example

  describe '#add_custom_examples_on' do
    before do
      subject.add_custom_examples_on :all, 'the shared examples'
    end

    it 'stores a custom_example reference into @custom_examples' do
      expect(subject.custom_examples).to include(filter: :all, name: 'the shared examples')
    end
  end
end
