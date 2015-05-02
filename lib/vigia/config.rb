module Vigia
  class Config
    attr_accessor :source_file, :host, :custom_examples_paths, :custom_examples, :headers, :http_client_class
    attr_accessor :adapter, :hooks, :rspec_config_block, :stderr, :stdout, :internal_hosts, :load_default_examples

    def initialize
      @host                  = nil
      @source_file           = nil
      @rspec_config_block    = nil
      @load_default_examples = true
      @internal_hosts        = []
      @headers               = {}
      @custom_examples_paths = []
      @custom_examples       = []
      @hooks                 = []
      @stderr                = $stderr
      @stdout                = $stdout
      @adapter               = Vigia::Adapters::Blueprint
      @http_client_class     = Vigia::HttpClient::RestClient
    end

    def validate!
      raise("You have to provide a host value in config or in the Apib") unless host

      true
    end

    def add_custom_examples_on(filter, name)
      @custom_examples << { filter: filter, name: name }
    end

    def rspec_config(&block)
      @rspec_config_block = block
    end

    def before_group(&block)
      store_hook(Vigia::Sail::GroupInstance, :before, block)
    end

    def after_group(&block)
      store_hook(Vigia::Sail::GroupInstance, :after, block)
    end

    def extend_group(&block)
      store_hook(Vigia::Sail::GroupInstance, :extend, block)
    end

    def before_context(&block)
      store_hook(Vigia::Sail::Context, :before, block)
    end

    def after_context(&block)
      store_hook(Vigia::Sail::Context, :after, block)
    end

    def extend_context(&block)
      store_hook(Vigia::Sail::Context, :extend, block)
    end

    def store_hook(rspec_class, filter, block)
      @hooks << { rspec_class: rspec_class, filter: filter,  block: block }
    end
  end
end
