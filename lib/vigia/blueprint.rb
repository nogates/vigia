# encoding: utf-8

module Vigia
  class Blueprint

    attr_reader :apib, :metadata

    def initialize apib_source
      @apib_parsed = RedSnow::parse(apib_source)
      @apib        = @apib_parsed.ast
      @metadata    = @apib.metadata
    end
  end
end
