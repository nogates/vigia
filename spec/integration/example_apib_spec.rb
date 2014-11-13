require 'spec_helper'
require 'support/integration_helper'

start_example_server
wait_until_ready

class Writer
  def self.file(resource_group, resource, action, transactional_example, response)
    File.open('/tmp/vigia_test', 'w') do |f|
      f.write "#{ resource_group.name }#{ resource.name }#{ action.name }#{ transactional_example.name }#{ response.name }"
    end
  end
end

# Configure Vigia to run spec/example.apib
Vigia.configure do |config|
  config.host        = Vigia::ExampleApp.host
  config.source_file = Vigia::ExampleTest.apib_path
  config.custom_examples_paths = File.join(__dir__, '../', 'support', 'shared_examples', 'my_custom_examples')

  config.headers = { testing_header: 'its value' }

  config.rspec_config do |rspec_config|
    rspec_config.reset
    rspec_config.formatter = RSpec::Core::Formatters::DocumentationFormatter
  end

  config.before_group   { }
  config.after_group    { }
  config.before_example { }
  config.after_example  { }
  config.before_context { }
  config.after_context  { }

  config.add_custom_examples_on(:all, 'my custom examples')
  config.add_custom_examples_on('Scenarios', 'scenarios resource examples')
  config.add_custom_examples_on('Retrieve all Scenarios', 'scenarios get index action examples')
end


# Run Vigia within RSpec process
require File.join(Vigia.spec_folder, 'api_spec')
