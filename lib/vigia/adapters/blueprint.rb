module Vigia
  module Adapters
    class Blueprint < Vigia::Adapter

      attr_reader :apib, :apib_source

      setup_adapter do

        after_initialize do
          @apib_source = File.read(source_file)
          @apib_parsed = RedSnow::parse(@apib_source, { :exportSourcemap => true })
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
            headers:      -> { adapter.headers_for(action, transactional_example, response) },
            method:       -> { action.method },
            uri_template: -> { resource.uri_template },
            parameters:   -> { adapter.parameters_for(resource, action) },
            payload:      -> { adapter.payload_for(transactional_example, response) if adapter.with_payload?(action) }
          },
          expectations: {
            code:    -> { response.name.to_i },
            headers: -> { adapter.headers_for(action, transactional_example, response, include_payload = false) },
            body:    -> { response.body }
          }
      end

      def headers_for(action, transactional_example, response, include_payload = true)
        headers  = headers_for_response(response)
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

      def inspector object
        case object
        when RedSnow::ResourceGroup
          locate_in_sourcemap(:resource_groups, object)
        when RedSnow::Resource
          locate_in_sourcemap(:resources, object)
        when RedSnow::Action
          locate_in_sourcemap(:actions, object)
        when RedSnow::TransactionExample
          first_response = object.responses.first
          locate_in_sourcemap(:responses, first_response)
        when RedSnow::Payload
          locate_in_sourcemap(:responses, object)
        else
          nil
        end
      end

      private

      def locate_in_sourcemap(key, object)
        node_index  = apib_structure[key].index(object)
        source_node = apib_sourcemap[key][node_index]
        character   = source_node.name.first.first

        { line: return_line_number_at_character_count(character) }
      end

      def return_line_number_at_character_count(number)
        total_chars = 0
        @apib_source.lines.each_with_index do |line, index|
          total_chars += line.length
          next if total_chars < number
          return index + 2
        end
      end

      def compile_headers(headers)
        headers.inject({}) do |hash, header|
          normalize_header_name = header[:name].gsub('-', '_').downcase.to_sym
          hash.merge!(normalize_header_name => header[:value])
        end
      end

      def headers_for_response(response)
        collection = []
        collection << [*response.headers.collection]
        collection.flatten
      end

      def apib_sourcemap
        @apib_sourcemap ||= build_structure(@apib_parsed.sourcemap)
      end

      def apib_structure
        @apib_structure ||= build_structure(apib)
      end

      def build_structure(start_point)
        {}.tap do |hash|
          hash[:resource_groups] = start_point.resource_groups
          hash[:resources]       = hash[:resource_groups].map(&:resources).flatten
          hash[:actions]         = hash[:resources].map(&:actions).flatten
          hash[:examples]        = hash[:actions].map(&:examples).flatten
          hash[:responses]       = hash[:examples].map(&:responses).flatten
        end
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
