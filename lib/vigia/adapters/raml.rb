module Vigia
  module Adapters
    class Raml < Vigia::Adapter

      attr_reader :raml

      setup_adapter do

        after_initialize do
          @raml = ::Raml::parse_file(source_file)
        end

        group :resource,
          primary:     true,
          children:    [ :method ],
          describes:   -> { adapter.raml.resources.values },
          description: -> { "Resource: #{ resource.name }" },
          recursion:   -> { resources.values }

        group :method,
          children:    [ :response ],
          describes:   -> { resource.methods.values },
          description: -> { "Method: #{ method.name }" }

        group :response,
          children:    [ :body ],
          describes:   -> { method.responses.values },
          description: -> { "Response: #{ response.name }" }

        group :body,
          contexts:    [ :default ],
          describes:   -> { response.bodies.values },
          description: -> { "Content type: #{ body.name }" }

        context :default,
          http_client_options: {
            method:        -> { method.name },
            uri_template:  -> { adapter.resource_uri_template(method) },
            parameters:    -> { adapter.parameters_for(method) },
            headers:       -> { adapter.request_headers(body) },
            payload:       -> { adapter.payload_for(method, body) if adapter.with_payload?(method.name) }
          },
          expectations: {
             code:    -> { response.name.to_i },
             headers: -> { adapter.expected_headers(body) },
             body:    -> { body.schema.value }
          }
      end

      def resource_uri_template(method)
        uri_template  = method.parent.resource_path
        uri_template += query_parameters(method)
      end

      def parameters_for(method)
        format_parameters(method.query_parameters) + format_parameters(method.parent.uri_parameters)
      end

      def request_headers(body)
        method = body.parent.parent
        compile_headers(method.headers).tap do |headers|
          return unless with_payload?(method.name)
          return if     request_body_for(method, body).name == '*/*'
          headers.merge!(content_type: request_body_for(method, body).name)
        end
      end

      def expected_headers(body)
        compile_headers(body.parent.headers).tap do |headers|
          # Dont add content_type header if response is 204 (nil response)
          headers.merge!(content_type: body.media_type) unless body.parent.name == 204 or headers.key?(:content_type)
        end
      end

      def payload_for(method, body)
        return unless with_payload?(method.name)
        request_body_for(method, body).schema.value
      end

      def with_payload?(method_name)
        [ :post, :put, :patch ].include?(method_name.to_s.downcase.to_sym)
      end

      private

      def format_parameters(raml_hash)
        raml_hash.values.each_with_object([]) do |parameter, array|
          array << { name: parameter.name, value: parameter.example, required: !parameter.optional }
        end
      end

      def compile_headers(headers)
        headers.each_with_object({}) do |(key, header), hash|
          raise "Required header #{ key } does not have an example value" if header.example.nil? && !header.optional
          hash.merge!(key.to_s.gsub('-', '_').downcase.to_sym => header.example)
        end
      end

      def request_body_for(method, response_body)
        body = response_body.name == '*/*' ? method.bodies.values.first : method.bodies[response_body.name]
        body ||raise("An example body cannot be found for method #{ method.name } #{ method.parent.resource_path }")
      end

      def query_parameters(method)
        method.apply_traits if method.traits.any? # Does this belong here RAML?
        return '' if method.query_parameters.empty?
        "{?#{ method.query_parameters.keys.join(',') }}"
      end
    end
  end
end
