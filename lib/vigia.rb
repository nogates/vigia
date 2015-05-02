# encoding: utf-8

require 'redsnow'
require 'raml'
require 'rspec'
require 'rest_client'
require 'addressable/template'

require_relative 'vigia/adapter'
require_relative 'vigia/adapters/blueprint'
require_relative 'vigia/adapters/raml'
require_relative 'vigia/config'
require_relative 'vigia/hooks'
require_relative 'vigia/formatter'
require_relative 'vigia/http_client/options'
require_relative 'vigia/http_client/rest_client'
require_relative 'vigia/http_client/requests'
require_relative 'vigia/parameters'
require_relative 'vigia/rspec'
require_relative 'vigia/sail/rspec_object'
require_relative 'vigia/sail/example'
require_relative 'vigia/sail/examples/default'
require_relative 'vigia/sail/context'
require_relative 'vigia/sail/group'
require_relative 'vigia/sail/group_instance'
require_relative 'vigia/url'
require_relative 'vigia/version'

module Vigia
  class << self

    attr_reader :config

    def configure
      reset!
      @config = Vigia::Config.new.tap do |_config|
        yield _config
        load_default_examples if _config.load_default_examples
      end
    end

    def spec_folder
      File.join(__dir__, 'vigia', 'spec')
    end

    def rspec!
      ensure_config
      Vigia::Rspec.new.run!
    end

    def reset!
      [ Vigia::Sail::Context, Vigia::Sail::Example, Vigia::Sail::Group ].map(&:clean!)
      @config = nil
    end

    private

    def load_default_examples
      Vigia::Sail::Examples::Default.load!
    end

    def ensure_config
      (config && config.validate!) || raise('Invalid config')
    end
  end
end
