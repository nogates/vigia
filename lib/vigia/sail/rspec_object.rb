module Vigia
  module Sail
    class RSpecObject
      class << self
        attr_accessor :collection

        def setup_and_run(name, rspec)
          name, options  = collection.select{ |k,v| k == name }.first
          instance       = new(name, options, rspec)
          instance.run
        end
      end

      attr_reader :name, :options, :rspec

      def initialize(name, options, rspec)
        @name    = name
        @options = options
        @rspec   = rspec

      end

      def execute_hook(filter_name, rspec_context)
        hooks_for_object(filter_name).each do |hook|
          rspec_context.instance_exec(&hook)
        end
      end

      def hooks_for_object(filter_name)
        config_hooks(filter_name) + object_hooks(filter_name)
      end

      def with_hooks(rspec_context)
        execute_hook(:before, rspec_context)
        yield
        execute_hook(:after, rspec_context)
      end

      def contextual_object(option_name: nil, object: nil, context: nil)
        context ||= rspec.described_class
        object  ||= options[option_name]
        case object
        when Symbol
          context.adapter.send(object)
        when Proc
          context.instance_exec(&object)
        else
          object
        end
      end

      private

      def object_hooks(filter_name)
        option_name = "#{ filter_name }_#{ self.class.name.split('::').last.downcase }".to_sym
        [ *options[option_name] ].compact

      end

      def config_hooks(filter_name)
        Vigia.config.hooks.each_with_object([]) do |hook, collection|
          next unless self.is_a?(hook[:rspec_class]) and filter_name == hook[:filter]
          collection << hook[:block]
        end
      end
    end
  end
end
