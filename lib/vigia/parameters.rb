module Vigia
  class Parameters

    attr_reader :resource, :action

    def initialize(resource, action)
      @resource = resource
      @action   = action
    end

    def to_hash
      all.each_with_object({}) do |parameter, collection|
        collection[parameter.name] = parameter.example_value
        collection
      end
    end

    def all
      resource.parameters.collection + action.parameters.collection
    end
  end
end
