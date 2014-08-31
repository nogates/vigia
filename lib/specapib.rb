# encoding: utf-8

require 'redsnow'
require 'rspec'
require 'rest_client'

require_relative 'specapib/example'
require_relative 'specapib/blueprint'
require_relative 'specapib/rspec'
require_relative 'specapib/config'
require_relative 'specapib/headers'
require_relative 'specapib/url'
require_relative 'specapib/version'
require_relative 'specapib/http_client/rest_client'

module SpecApib
  class << self
    def config
      @config
    end
    def configure
      @config = SpecApib::Config.new
      yield @config
      @config.validate!
    end
    def spec_folder
      File.join(__dir__, 'specapib', 'spec')
    end
    def rspec!
      SpecApib::Rspec.new.run!
    end
  end
end
