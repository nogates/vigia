module Vigia
  class Adapter

    attr_accessor :source_file, :structure

    class << self
      def setup_adapter(&block)
        raise 'You have to call config_adapter with a block' unless block_given?
        @template = block
      end

      def template
        @template
      end

      def instance
        new.tap do |object|
          object.source_file = Vigia.config.source_file
          object.structure   = Structure.generate(object, @template)
          object
        end
      end
    end

    def with_payload?(method)
      [ :post, :patch, :put, :delete ].include?(method.to_s.downcase.to_sym)
    end

    def required_payload?(method)
      [ :post, :patch, :put ].include?(method.to_s.downcase.to_sym)
    end

    class Structure
      class << self
        def generate(adapter, structure)
          instance = new(adapter, structure)
          instance.preload
          instance
        end
      end

      attr_reader :adapter, :groups, :contexts, :template

      def initialize(adapter, template)
        @adapter   = adapter
        @template  = template
        @groups    = {}
        @contexts  = {}
      end

      def preload
        instance_exec(&template)

        groups.each   { |name, options| Vigia::Sail::Group.register(name, options) }
        contexts.each { |name, options| Vigia::Sail::Context.register(name, options) }
      end

      def after_initialize(&block)
        adapter.instance_exec(&block)
      end

      def group(name, options = {})
        @groups.merge!(name => options)
      end

      def context(name, options = {})
        @contexts.merge!(name => options)
      end
    end
  end
end
