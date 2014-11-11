module Vigia
  class Parameters

    attr_reader :parameters

    def initialize(parameters)
      @parameters = parameters
      validate
    end

    def to_hash
      @parameters.each_with_object({}) do |parameter, hash|
        hash.merge!(parameter[:name] => parameter[:value])
      end
    end

    def validate
      return if required_parameters.empty?

      raise("Missing parameters #{ missing_parameters.join(',') }") unless missing_parameters.empty?
    end

    private

    def required_parameters
      parameters.select{ |k| k[:required] == true }
    end

    def missing_parameters
      required_parameters.select{ |k| k[:value].nil? || k[:value].empty? }.map{ |k| k[:name] }
    end
  end
end
