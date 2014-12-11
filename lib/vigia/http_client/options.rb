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
          instance.use_uri_template       if instance.uri_template
          instance.set_internal_server    if instance.internal_server?
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

      def set_internal_server
        vigia_uri = URI.parse(Vigia.config.host)
        uri.host   = vigia_uri.host
        uri.port   = vigia_uri.port
        uri.scheme = vigia_uri.scheme
        self.url   = uri.to_s
      end

      def internal_server?
        Vigia.config.internal_hosts.include?(url_host)
      end

      def url_host
        uri.host
      end

      def uri
        @uri ||= URI.parse(self['url'])
      end

      def include_config_headers
        (self.headers || {}).merge!(Vigia.config.headers)
      end
    end
  end
end
