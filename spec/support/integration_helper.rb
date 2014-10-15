require_relative 'integration_classes'

def start_example_server
  example_server = Vigia::ExampleServer.new
  example_server.async.start!
end

def wait_until_ready
  keep_waiting = true
  while keep_waiting
    sleep 1
    keep_waiting = false unless Vigia::ExampleApp.running_server.nil?
  end
end
