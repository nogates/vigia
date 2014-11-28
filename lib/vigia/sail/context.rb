module Vigia
  module Sail
    class Context < RSpecObject

      def run
        instance = self
        rspec.context instance.to_s do
          instance.with_hooks(self) do
            let(:http_client_options) { instance.set_http_client_options(self) }
            let(:expectations)        { instance.set_expectations(self) }

            instance.run_examples(self)
            instance.run_shared_examples(self)
          end
        end
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

      def run_shared_examples(in_context)
        if custom_examples.any?
          custom_examples.each do |example_name|
            in_context.include_examples example_name
          end
        end
      end

      def to_s
        "context #{ name }"
      end

      private

      def custom_examples
        Vigia.config.custom_examples.each_with_object([]) do |custom_example, collection|
           collection << custom_example[:name] if custom_example[:filter] == :all
           collection
        end
      end

      def expectations
        (options[:expectations] || {}).keys & default_expectations
      end

      def default_expectations
        [ :code, :headers, :body ]
      end
    end
  end
end

