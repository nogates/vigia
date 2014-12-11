# encoding: utf-8

require 'redsnow'
require 'rspec'
require 'rest_client'
require 'addressable/template'

require_relative 'vigia/adapter'
require_relative 'vigia/adapters/blueprint'
require_relative 'vigia/config'
require_relative 'vigia/hooks'
require_relative 'vigia/http_client/options'
require_relative 'vigia/http_client/rest_client'
require_relative 'vigia/http_client/requests'
require_relative 'vigia/parameters'
require_relative 'vigia/rspec'
require_relative 'vigia/sail/rspec_object'
require_relative 'vigia/sail/example'
require_relative 'vigia/sail/context'
require_relative 'vigia/sail/group'
require_relative 'vigia/sail/group_instance'
require_relative 'vigia/url'
require_relative 'vigia/version'

module Vigia
  class << self
    def config
      @config
    end
    def configure
      @config = Vigia::Config.new
      yield @config
      @config.apply
    end
    def spec_folder
      File.join(__dir__, 'vigia', 'spec')
    end
    def rspec!
      Vigia::Rspec.new.run!
    end
  end
end

require_relative 'vigia/sail/examples/default'
