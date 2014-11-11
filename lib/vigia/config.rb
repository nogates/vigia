module Vigia
  class Config
    attr_accessor :source_file, :host, :custom_examples_paths, :custom_examples, :headers, :http_client_class, :adapter, :hooks, :rspec_config_block

    def initialize
      @host                  = nil
      @source_file           = nil
      @rspec_config_block    = nil
      @headers               = {}
      @custom_examples_paths = []
      @custom_examples       = []
      @hooks                 = []
      @adapter               = Vigia::Adapters::Blueprint
      @http_client_class     = Vigia::HttpClient::RestClient
    end

    def apply
      validate!
    end

    def validate!
      raise("You need to provide an source") unless source_file
      raise("You have to provide a host value in config or in the Apib") unless host
    end

    def add_custom_examples_on(filter, name)
      @custom_examples << { filter: filter, name: name }
    end

    def rspec_config(&block)
      @rspec_config_block = block
    end

    def before_group(&block)
      store_hook(Vigia::Sail::Group, :before, block)
    end

    def after_group(&block)
      store_hook(Vigia::Sail::Group, :after, block)
    end

    def before_context(&block)
      store_hook(Vigia::Sail::Context, :before, block)
    end

    def after_context(&block)
      store_hook(Vigia::Sail::Context, :after, block)
    end

    def before_example(&block)
      store_hook(Vigia::Sail::Example, :before, block)
    end

    def after_example(&block)
      store_hook(Vigia::Sail::Example, :after, block)
    end

    def store_hook(rspec_class, filter, block)
      @hooks << { rspec_class: rspec_class, filter: filter,  block: block }
    end
  end
end
