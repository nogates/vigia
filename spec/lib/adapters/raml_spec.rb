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

  describe '#expected_headers' do
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

  describe '#format_parameters' do
    let(:method) do
      instance_double(
        Raml::Method,
        parent:           resource,
        query_parameters: parameters
      )
    end
    let(:resource)          { double(uri_parameters: {}) }
    let(:parameters)        { {} }

    context 'when the method parameters includes rfc 3986 chars in the name' do
      let(:parameters)        { { "api#{ char }key" => api_key_parameter } }
      let(:api_key_parameter) do
        instance_double(
          Raml::Parameter::UriParameter,
          name:     "api#{ char }key",
          example:  '123',
          optional: true
        )
      end


      context 'when the char is an hyphen' do
        let(:char) { '-' }

        it 'formats the paramter name properly' do
          expect(subject.parameters_for(method)).to eq [
            { name: 'api%2Dkey', value: '123', required: false }
          ]
        end
      end

      context 'when the char is a tilde' do
        let(:char) { '~' }

        it 'formats the paramter name properly' do
          expect(subject.parameters_for(method)).to eq [
            { name: 'api%7Ekey', value: '123', required: false }
          ]
        end
      end

      context 'when the char is a dot' do
        let(:char) { '.' }

        it 'formats the paramter name properly' do
          expect(subject.parameters_for(method)).to eq [
            { name: 'api%2Ekey', value: '123', required: false }
          ]
        end
      end

      context 'when multiple' do
        let(:char) { '.~-.' }

        it 'formats the paramter name properly' do
          expect(subject.parameters_for(method)).to eq [
            { name: 'api%2E%7E%2D%2Ekey', value: '123', required: false }
          ]
        end
      end
    end
  end

  describe '#payload_for' do
    let(:method) do
      instance_double(
        Raml::Method,
        parent: parent,
        name:   method_name,
        bodies: bodies
      )
    end
    let(:parent)    { nil }
    let(:bodies)    { {} }
    let(:body)      { double(name: body_name) }
    let(:body_name) { 'body_name' }

    context 'when the method is not :post, :put, :patch or :delete' do
      let(:method_name) { :get }

      it 'returns nil' do
        expect(subject.payload_for(method, body)).to be nil
      end
    end

    [ :post, :patch, :put, :delete ].each do |verb|
      context "when the method is #{ verb }" do
        let(:method_name) { verb }

        context 'when the method has bodies' do
          let(:json_body)   { double(example: 'json') }
          let(:xml_body)    { double(example: 'xml') }
          let(:bodies) do
            {
              'application/json' => json_body,
              'application/xml'  => xml_body
            }
          end

          context 'when the body name is `*/*`' do
            let(:body_name) { '*/*' }

            it 'returns the first method body' do
              expect(subject.payload_for(method, body)).to eq 'json'
            end
          end

          context 'when the body name is not `*/*`' do
            let(:body_name) { 'application/xml' }

            it 'returns the proper body' do
              expect(subject.payload_for(method, body)).to eq 'xml'
            end
          end

          context 'when the body example is nil' do
            let(:body_name) { 'application/xml' }
            let(:schema)    { double(value: 'xml scheme') }
            let(:xml_body)  { double(example: nil, schema: schema) }

            it 'returns uses the scheme value' do
              expect(subject.payload_for(method, body)).to eq 'xml scheme'
            end
          end
        end
      end
    end

    context 'when the method does not have bodies' do
      let(:body_name) { '*/*' }
      let(:bodies)    { {} }
      let(:parent)    { double(resource_path: resource_template) }
      let(:resource_template) { '/posts' }

      [ :post, :patch, :put ].each do |verb|
        context "when the method is #{ verb }" do
          let(:method_name) { verb }

          it 'raises an exception' do
            expect { subject.payload_for(method, body) }
              .to raise_error "An example body cannot be found for method #{ verb } /posts"
          end
        end
      end

      context 'when the method is :delete' do
        let(:method_name) { :delete }

        it 'returns nil' do
          expect(subject.payload_for(method, body)).to be nil
        end
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

    context 'when a query parameter contains an hyphen' do
      let(:parameters) { { :"api-key" => 'The API Key' } }

      it 'returns the resource template with the hyphen encoded' do
        expect(subject.resource_uri_template(method)).to eql('/posts{?api%2Dkey}')
      end
    end
  end
end
