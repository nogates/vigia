module Vigia
  module HttpClient
    class Options < OpenStruct
      class << self
        def build(context, in_let_context)
          instance = new
          instance.context = context
          instance.options.each do |name, value|
            instance[name] = context.contextual_object(object: value, context: in_let_context)
          end
          instance.headers ||= {}
          instance.use_uri_template       if instance.uri_template
          instance.include_config_headers if Vigia.config.headers.any?
          instance
        end
      end

      def options
        context.options[:http_client_options] || {}
      end

      def use_uri_template
        self.url = Vigia::Url.new(uri_template).expand(parameters)
      end

      def include_config_headers
        self.headers.merge!(Vigia.config.headers)
      end
    end
  end
end
