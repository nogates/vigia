module SpecApib
  class Example

    attr_reader :action, :resource, :apib_example, :requests, :headers

    def initialize(resource:, action:, apib_example:)
      @resource     = resource
      @action       = action
      @apib_example = apib_example
      @error        = []
      @requests     = {}
      @headers      = SpecApib::Headers.new(resource)
      @url          = SpecApib::Url.new(
                        uri_template: resource.uri_template,
                        parameters:   parameters)
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

    def compile_url
      @url.to_s
    end

    def custom_examples
      SpecApib.config.custom_examples_for(self)
    end

    private
    def parameters
      resource.parameters.collection + action.parameters.collection
    end

    def http_options_for(response)
      options = default_http_options_for(response)

      if with_payload?
        options.merge!(payload: request_for(response).body)
      end

      options
    end

    def http_client_request(http_options)
      instance = SpecApib.config.http_client_class.new(http_options)
      instance.run!
    end

    def default_http_options_for(response)
      options = {
        method:  action.method,
        url:     compile_url,
        headers: compile_headers(response)
      }
    end

    def compile_headers(response)
      if with_payload?
        @headers.http_client_with_payload(response, request_for(response))
      else
        @headers.http_client(response)
      end
    end

    def with_payload?
      %w(POST PUT).include? action.method
    end

    def request_for(response)
      index = apib_example.responses.index(response)
      apib_example.requests.at(index)
    rescue => e
      raise "Unable to load payload for response #{ response.name }"
    end
  end
end
