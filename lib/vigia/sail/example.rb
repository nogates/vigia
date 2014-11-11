module Vigia
  module Sail
    class Example < Vigia::Sail::RSpecObject
      class << self

        def register(name, options = {})
          @collection = {} if collection.nil?
          @collection.merge!(name => options)
        end

        def run_in_context(lookout, rspec_context)
          examples_for_context(lookout, rspec_context).map do |example|
            example.with_hooks do
              example.run
            end
          end
        end

        def examples_for_context(lookout, rspec_context)
          @collection.select do |name, options|
            valid_contexts = [ *(options[:contexts] || :default) ]
            valid_contexts.include?(lookout.name)
          end.map do |name, options|
            new(name, options, rspec_context)
          end
        end
      end

      def run
        instance = self
        rspec.it instance do
          skip              if instance.skip?(self)     || (respond_to?(:skip?)     and send(:skip?))
          skip('__vigia__') if instance.disabled?(self) || (respond_to?(:disabled?) and send(:disabled?))

          instance_exec(&instance.options[:expectation]) # FIXME
        end
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


Vigia::Sail::Example.register(
  :code_match,
  description: 'has the expected HTTP code',
  expectation: -> { expect(result.code).to be(expectations.code) }
)

Vigia::Sail::Example.register(
  :include_headers,
  description: 'includes the expected headers',
  expectation: -> { expect(result[:headers]).to include(expectations[:headers]) }
)
