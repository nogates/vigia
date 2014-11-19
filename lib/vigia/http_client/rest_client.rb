module Vigia
  module HttpClient
    class RestClient
      attr_accessor :code, :headers, :body

      def initialize(http_client_options)
        @http_client_options = http_client_options
      end

      def run
        cache_or_perform_request
      end

      def run!
        perform_request
      end

      private

      # FIXME move cache to HttpClient::Base
      def cache_or_perform_request
        if cache.has_key?(request_key)
          cache[request_key]
        else
          @@cache[request_key] = perform_request
        end
      end

      def cache
        @@cache ||= {}
      end

      def request_key
        hash = @http_client_options.to_h.select do |k,v|
          [ :headers, :method, :url, :payload ].include?(k)
        end
        Digest::MD5.hexdigest(hash.to_s)
      end

      def parse_request(rest_client_result)
        Vigia::HttpClient::ClientRequest.new(
          code:    rest_client_result.code,
          headers: rest_client_result.headers,
          body:    rest_client_result.body
        )
      end

      def error_request(exception)
        Vigia::HttpClient::ClientRequest.new(
          code:    exception.http_code, # Todo. Parse each exception
          headers: exception.response.headers,
          body:    exception.http_body
        )
      end

      def perform_request
        begin
          request = ::RestClient::Request.execute(@http_client_options.to_h)
          parse_request(request)
        rescue ::RestClient::Exception => exception
          error_request(exception)
        end
      end
    end
  end
end
