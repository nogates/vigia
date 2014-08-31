module SpecApib

  class Config

    attr_accessor :apib_path, :host, :custom_examples_paths, :custom_examples, :headers, :http_client_class

    def initialize
      @host                  = nil
      @apib_path             = nil
      @headers               = {}
      @custom_examples_paths = []
      @custom_examples       = []
      @http_client_class     = SpecApib::HttpClient::RestClient
    end

    def validate!
      raise("You need to provide an apib_path") unless @apib_path
      raise("You have to provide a host value in config or in the Apib") unless host
    end

    def add_custom_examples_on(namespace, examples_name)
      @custom_examples << { namespace: namespace, examples_name: examples_name }
    end

    def host
      @host || blueprint.metadata['host']
    end

    def custom_examples_for(example)
      @custom_examples.each_with_object([]) do |custom_example, collection|
        if custom_example[:namespace] == :all
          collection << custom_example
        end # ToDo: Find a way to provide custom examples for each SpecApib Example. Through example.id?
        collection
      end
    end

    def blueprint
      @blueprint ||= SpecApib::Blueprint.new(File.read(apib_path))
    end
  end
end
