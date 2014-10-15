module Vigia
  class Config
    attr_accessor :apib_path, :host, :custom_examples_paths, :custom_examples, :headers, :http_client_class

    def initialize
      @host                  = nil
      @apib_path             = nil
      @headers               = {}
      @custom_examples_paths = []
      @custom_examples       = []
      @http_client_class     = Vigia::HttpClient::RestClient
    end

    def validate!
      raise("You need to provide an apib_path") unless @apib_path
      raise("You have to provide a host value in config or in the Apib") unless host
    end

    def add_custom_examples_on(filter, name)
      @custom_examples << { filter: filter, name: name }
    end

    def host
      @host || blueprint.metadata['host']
    end

    def custom_examples_for(specpaib_example)
      custom_examples.each_with_object([]) do |custom_example, collection|
        collection << custom_example[:name] if eligible_example?(specpaib_example, custom_example[:filter])
        collection
      end
    end

    def blueprint
      @blueprint ||= Vigia::Blueprint.new(File.read(apib_path))
    end

    private

    def eligible_example?(specpaib_example, filter)
      return true if filter == :all

      [ specpaib_example.resource.name, specpaib_example.action.name ].include?(filter)
    end
  end
end
