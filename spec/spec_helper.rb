require 'specapib'
require 'pry'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f}

module SpecApib
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
        SpecApib::ExampleServer
      end

      def app
        SpecApib::ExampleApp
      end
    end
  end
end
