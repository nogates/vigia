require 'vigia'
require 'pry'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f}

module Vigia
  class ExampleTest
    class << self
      def apib
        RedSnow::parse apib_source
      end

      def apib_source
        File.read apib_path
      end

      def apib_path
        File.join __dir__, 'example.apib'
      end

      def server
        Vigia::ExampleServer
      end

      def app
        Vigia::ExampleApp
      end
    end
  end
end
