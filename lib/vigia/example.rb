module Vigia
  class Example

    attr_reader :action, :resource, :apib_example, :requests, :headers

    def initialize(resource:, action:, apib_example:)
      @resource     = resource
      @action       = action
      @apib_example = apib_example
      @error        = []
      @requests     = {}
      @parameters   = Vigia::Parameters.new(resource, action)
      @headers      = Vigia::Headers.new(resource)
      @url          = Vigia::Url.new(resource.uri_template)
    end

    # do the request only once ??
    def perform_request(response)
      return @requests[response.name] if @requests.key?(response.name)

      @requests[response.name] = http_client_request(http_options_for(response))
      @requests[response.name]
    end

    def expectations_for(response)
      {
        code:    response.name.to_i,
        headers: @headers.expected(response),
        body:    response.body
      }
    end

    def url
      @url.expand(parameters)
    end

    def custom_examples
      Vigia.config.custom_examples_for(self)
    end

    def skip?
      resource.description.include?('@skip') or action.description.include?('@skip')
    end

    private

    def parameters
      @parameters.to_hash
    end

    def http_options_for(response)
      options = default_http_options_for(response)

      if with_payload?
        options.merge!(payload: request_for(response).body)
      end

      options
    end

    def http_client_request(http_options)
      Vigia.config.http_client_class.new(http_options).run!
    end

    def default_http_options_for(response)
      options = {
        method:  action.method,
        url:     url,
        headers: headers(response)
      }
    end

    def headers(response)
      if with_payload?
        @headers.http_client_with_payload(response, request_for(response))
      else
        @headers.http_client(response)
      end
    end

    def with_payload?
      %w(POST PUT PATCH).include? action.method
    end

    def request_for(response)
      index = apib_example.responses.index(response)
      apib_example.requests.fetch(index)
    rescue => e
      raise "Unable to load payload for response #{ response.name }"
    end
  end
end
