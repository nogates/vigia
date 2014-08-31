module SpecApib
  class Headers
    
    # ToDo: resource should be an instance variable
    def initialize(resource)
      @resource = resource
    end
    
    def expected(response)
      compile_headers(headers_for_response(response))
    end
    
    def http_client(response)
      compile_headers(headers_for_response(response)).merge(config_headers)
    end
    
    def http_client_with_payload(response, payload)
      compile_headers(headers_for_response_and_payload(response, payload)).merge(config_headers)
    end

    private
    def compile_headers(headers, options = {})
      headers.inject({}) do |hash, header|
        # Find a better way to match headers in expectations (Hash with indifferent access?).s
        # Right now, this is needed to match RestClient headers format.
        normalize_header_name = header[:name].gsub('-', '_').downcase.to_sym
        hash.merge!(normalize_header_name => header[:value])
      end
    end

    def config_headers
      SpecApib.config.headers
    end

    def headers_for_response(response)
      collection = []
      collection << [*@resource.model.headers.collection]
      collection << [*response.headers.collection]
      collection.flatten
    end
    
    def headers_for_response_and_payload(response, payload)
      collection = headers_for_response(response)
      collection << [*payload.headers.collection]
      collection.flatten
    end
  end
end
