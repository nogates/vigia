require 'spec_helper'
require 'support/integration_helper'

start_example_server
wait_until_ready

# Configure SpecApib to run spec/example.apib
SpecApib.configure do |config|
  config.host      = SpecApib::ExampleApp.host
  config.apib_path = SpecApib::ExampleTest.apib_path
  config.custom_examples_paths = File.join(__dir__, '../', 'support', 'shared_examples', 'my_custom_examples')
  config.add_custom_examples_on(:all, 'my custom examples')
  config.add_custom_examples_on('Scenarios', 'scenarios resource examples')
  config.add_custom_examples_on('Retrieve all Scenarios', 'scenarios get index action examples')
end

# Run SpecApib within RSpec process
require File.join(SpecApib.spec_folder, 'api_spec')

