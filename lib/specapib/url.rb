module SpecApib
  class Url

    def initialize(uri_template:, parameters:)
      @uri_template = uri_template
      @parameters   = parameters
    end

    def to_s
      url = @uri_template.clone
      url = modify_url_parameters(url)
      url = modify_query_parameters(url)
      "#{ host }#{ url }"
    end

    def host
      SpecApib.config.host
    end

    def modify_query_parameters(url)
      modify_group(url, query_parameter_regexp) do |group|
        changes = each_parameter_in(group, /[{?}]/) do |parameter, collection|
          if valid_parameter?(parameter)
            collection << "#{ parameter.name }=#{ parameter.example_value }"
          end
          collection
        end
        changes.empty? ? '' : "?#{ changes.join('&') }"
      end
    end

    def modify_url_parameters(url)
      modify_group(url, url_parameter_regexp) do |group|
        changes = each_parameter_in(group, /[{}]/) do |parameter, collection|
          if valid_parameter?(parameter)
            collection << parameter.example_value
          else
            raise("Invalid Url Parameter #{ parameter }")
          end
          collection
        end
        changes.join('/')
      end
    end

    private

    def get_parameter parameter_name
      @parameters.select{|parameter| parameter.name == parameter_name }.first
    end

    def url_parameter_regexp
      /(^{.)*\{([\w,&&[^{]]*)\}(^{.)*/
    end

    def query_parameter_regexp
      /(^{.)*\{\?([\w,&&[^{]]*)\}(^{.)*/
    end

    def modify_group(url, regexp, &block)
      url.gsub(regexp) do |group|
        yield group
      end
    end

    def each_parameter_in(group, regexp, &block)
      parameters = group.gsub(regexp, '').split(',')
      parameters.each_with_object [] do |parameter_name, collection|
        parameter  = get_parameter(parameter_name)
        collection = yield parameter, collection
      end
    end

    def valid_parameter?(parameter)
      !parameter.nil? && !parameter.example_value.nil?
    end
  end
end
