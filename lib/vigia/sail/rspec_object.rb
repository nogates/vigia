module Vigia
  module Sail
    class RSpecObject
      class << self
        attr_reader :collection

        def register(name, options)
          @collection = {} if collection.nil?
          @collection.merge!(name => options)
        end

        def setup_and_run(name, rspec)
          name, options  = collection.select{ |k,v| k == name }.first
          instance       = new(name, options, rspec)
          instance.run
        end
      end

      include Vigia::Hooks

      attr_reader :name, :options, :rspec

      def initialize(name, options, rspec)
        @name    = name
        @options = options
        @rspec   = rspec

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

      def must_be_a_block(block, error_message)
        return block if block.respond_to?(:call)
        raise error_message
      end
    end
  end
end
