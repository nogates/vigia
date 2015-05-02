require 'spec_helper'

describe Vigia::Adapters::Raml do

  let(:config) do
    instance_double(
      Vigia::Config,
      source_file: 'my_raml_file'
    )
  end

  before do
    Vigia.reset!
    allow(Vigia).to receive(:config).and_return(config)
  end

  describe 'adapter structure' do
    context 'testing an instance' do
      # using cucumber my_blog.raml
      let(:instance) { described_class.instance }

      before do
        allow(config).to receive(:source_file)
          .and_return(File.join(__dir__, '../../../features/support/examples/my_blog/my_blog.raml'))
        instance
      end

      it 'loads up the sail groups' do
        expect(Vigia::Sail::Group.collection.keys)
          .to match_array [ :resource, :method, :response, :body ]
      end

      it 'loads up the sail contexts' do
        expect(Vigia::Sail::Context.collection.keys)
          .to match_array [ :default ]
      end
    end
  end

  describe 'expected_headers' do
    let(:body)          { double(parent: response) }
    let(:response)      { double(headers: headers, name: response_name) }
    let(:response_name) { 200 }
    let(:headers)       { { content_type: content_type } }
    let(:content_type)  { double(optional: optional, example: example) }

    context 'when the header is required and example is nil' do
      let(:optional) { false }
      let(:example)  { nil }

      it 'raises an exception' do
        expect { subject.expected_headers(body) }
          .to raise_error 'Required header content_type does not have an example value'
      end
    end

    context 'when the header is not required' do
      let(:optional) { true }
      let(:example)  { nil }

      it 'returns the header with a nil value' do
        expect(subject.expected_headers(body)).to eql(content_type: nil)
      end
    end
  end

  describe '#resource_uri_template' do
    let(:method) do
      instance_double(
        Raml::Method,
        parent: resource,
        query_parameters: parameters,
        traits: {}
      )
    end
    let(:resource)          { double(resource_path: resource_template) }
    let(:resource_template) { '/posts' }

    context 'when method does not hash query parameters' do
      let(:parameters) { {} }

      it 'returns the resource template itself' do
        expect(subject.resource_uri_template(method)).to eql('/posts')
      end
    end

    context 'when method has query parameters' do
      let(:parameters) { { page: 'A parameter', sort: 'Another parameter' } }

      it 'returns the resource template with the query parameters' do
        expect(subject.resource_uri_template(method)).to eql('/posts{?page,sort}')
      end
    end
  end
end
