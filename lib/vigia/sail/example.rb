module Vigia
  module Sail
    class Example < Vigia::Sail::RSpecObject
      class << self
        def register(name, options)
          @collection = {} if collection.nil?
          @collection.merge!(name => options)
        end

        def run_in_context(context, rspec_context)
          @collection.each do |name, options|
            setup_and_run(name, rspec_context) if example_contexts_include?(context, options[:contexts])
          end
        end

        def example_contexts_include?(context, enabled_contexts)
          [ *(enabled_contexts || :default) ].include?(context.name)
        end
      end

      def run
        instance = self
        rspec.it instance do
          skip              if instance.skip?(self)     || (respond_to?(:skip?)     and send(:skip?))
          skip('__vigia__') if instance.disabled?(self) || (respond_to?(:disabled?) and send(:disabled?))

          instance_exec(&instance.expectation)
        end
      end

      def expectation
        must_be_a_block(options[:expectation], "Example `#{ name }` expectation must be a block")
      end

      def to_s
        return contextual_object(option_name: :description) if options[:description]

        name.to_s
      end

      def skip?(in_context)
        return false unless options[:skip_if]
        contextual_object(option_name: :skip_if, context: in_context)
      end

      def disabled?(in_context)
        return false unless options[:disable_if]
        contextual_object(option_name: :disable_if, context: in_context)
      end
    end
  end
end
