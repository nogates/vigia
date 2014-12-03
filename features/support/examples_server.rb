require 'celluloid/autostart'

module Vigia
  module Examples
    class Server
      include Celluloid
      attr_accessor :app

      def start!
        app.run!
      end
    end
  end
end
