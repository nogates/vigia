module Vigia
  module HttpClient
    class RestClient
      attr_accessor :code, :headers, :body

      def initialize(http_options)
        @http_options = http_options
      end

      def run!
        perform_request
      end

      private

      def parse_request(rest_client_result)
        {
          code: rest_client_result.code,
          headers: rest_client_result.headers,
          body: rest_client_result.body
        }
      end

      def error_request(exception)
        {
          code: exception.http_code, # Todo. Parse each exception
          headers: exception.response.headers,
          body: exception.response
        }
      end

      def perform_request
        begin
          request = ::RestClient::Request.execute(@http_options)
          parse_request(request)
        rescue ::RestClient::Exception => exception
          error_request(exception)
        end
      end
    end
  end
end
