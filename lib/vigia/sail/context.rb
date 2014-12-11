module Vigia
  module Sail
    class Context < RSpecObject

      def run
        run_rspec_context unless disabled?
      end

      def set_http_client_options(in_let_context)
        Vigia::HttpClient::Options.build(self, in_let_context)
      end

      def set_expectations(in_let_context)
        Vigia::HttpClient::ExpectedRequest.new.tap do |instance|
          expectations.each do |name|
            option_object  = options[:expectations][name]
            instance[name] = contextual_object(object: option_object, context: in_let_context)
          end
          instance
        end
      end

      def run_examples(in_context)
        Vigia::Sail::Example.run_in_context(self, in_context)
      end

      def run_children(in_context)
        children.each do |context_name|
          Vigia::Sail::Context.setup_and_run(context_name, in_context)
        end
      end

      def run_shared_examples(in_context)
        if custom_examples.any?
          custom_examples.each do |example_name|
            in_context.include_examples example_name
          end
        end
      end

      def run_rspec_context
        instance = self
        rspec.context instance.to_s, context: instance  do
          define_singleton_method("context_#{ instance.name }", ->{ instance })

          instance.with_hooks(self) do

            let(:http_client_options) { instance.set_http_client_options(self) } if instance.options[:http_client_options]
            let(:expectations)        { instance.set_expectations(self) }

            instance.run_examples(self)
            instance.run_shared_examples(self)
            instance.run_children(self)
          end
        end
      end

      def to_s
        (contextual_object(option_name: :description) || "context #{ name }").to_s
      end

      private

      def custom_examples
        Vigia.config.custom_examples.each_with_object([]) do |custom_example, collection|
           collection << custom_example[:name] if [ :all, name ].include?(custom_example[:filter])
           collection
        end
      end

      def expectations
        (options[:expectations] || {}).keys & default_expectations
      end

      def default_expectations
        [ :code, :headers, :body ]
      end

      def disabled?
        return false unless options[:disable_if]
        contextual_object(option_name: :disable_if)
      end

      def children
        (self.class.collection.select do |k,v|
          v.has_key?(:in_contexts) && [ *v[:in_contexts] ].include?(name)
        end.keys + ([ *options[:contexts] ] || [])).uniq
      end
    end
  end
end

