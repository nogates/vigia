module Vigia
  module Examples
    class MyBlog
      def start_server
        @server     = Vigia::Examples::Server.new
        @server.app = app
        @server.async.start!
        wait_until(app_started?)
      end
      def stop_server
        app.quit!
        wait_until(app_stopped?)
        @server.terminate!
      end
      def app
        Vigia::Examples::MyBlog::App
      end
      def host
        app.host
      end

      def app_started?
        app.running_server.nil?
      end

      def app_stopped?
        not app_started?
      end

      def wait_until(wait)
        sleep 1 if wait
      end
    end
  end
end
