module Vigia
  module Adapters
    class Blueprint < Vigia::Adapter

      attr_reader :apib

      config_adapter do

        after_initialize do
          @apib_parsed = RedSnow::parse(File.read(source_file))
          @apib        = @apib_parsed.ast
        end

        group :resource_group,
          primary:     true,
          children:    [ :resource ],
          describes:   -> { adapter.apib.resource_groups },
          description: -> { "Resource Group: #{ resource_group.name }" }

        group :resource,
          children:    [ :action ],
          describes:   -> { resource_group.resources },
          description: -> { "Resource: #{ resource.name }" }

        group :action,
          children:    [ :transactional_example ],
          describes:   -> { resource.actions },
          description: -> { action.method }

        group :transactional_example,
          children: [ :response ],
          describes: -> { action.examples },
          description: -> { "Example ##{ parent_object.examples.index(transactional_example) }" }

        group :response,
          contexts:     [ :default ],
          describes:   -> { transactional_example.responses },
          description: -> { "Running Response #{ response.name }" }

        context :default,
          http_client_options: {
            headers:      -> { adapter.headers_for(resource, action, transactional_example, response) },
            method:       -> { action.method },
            uri_template: -> { resource.uri_template },
            parameters:   -> { adapter.parameters_for(resource, action) },
            payload:      -> { adapter.payload_for(transactional_example, response) if adapter.with_payload?(action) }
          },
          expectations: {
            code:    -> { response.name.to_i },
            headers: -> { adapter.headers_for(resource, action, transactional_example, response, include_payload = false) },
            body:    -> { response.body }
          },
          after_context: -> {  }
      end

      def headers_for(resource, action, transactional_example, response, include_payload = true)
        headers  = headers_for_response(resource, response)
        headers += headers_for_payload(transactional_example, response) if with_payload?(action) && include_payload
        compile_headers(headers)
      end

      def parameters_for(resource, action)
        (resource.parameters.collection + action.parameters.collection).each_with_object([]) do |parameter, collection|
          collection << { name: parameter.name, value: parameter.example_value, required: (parameter.use == :required) }
        end
      end

      def with_payload?(action)
        %w(POST PUT PATCH).include? action.method
      end

      def payload_for(transactional_example, response)
        payload = get_payload(transactional_example, response)
        payload.body
      end

      private

      def compile_headers(headers)
        headers.inject({}) do |hash, header|
          normalize_header_name = header[:name].gsub('-', '_').downcase.to_sym
          hash.merge!(normalize_header_name => header[:value])
        end
      end

      def headers_for_response(resource, response)
        collection = []
        collection << [*resource.model.headers.collection]
        collection << [*response.headers.collection]
        collection.flatten
      end

      def headers_for_payload(transactional_example, response)
        payload = get_payload(transactional_example, response)
        [ *payload.headers.collection ].flatten
      end

      def get_payload(transactional_example, response)
        index = transactional_example.responses.index(response)
        transactional_example.requests.fetch(index)
      rescue => e
        raise "Unable to load payload for response #{ response.name }"
      end
    end
  end
end
