require 'spec_helper'
require 'support/integration_helper'

start_example_server
wait_until_ready


# This example ensures before_group is working properly and setting each group object name
Vigia::Sail::Example.register(:valid_before_hooks,
  expectation: -> {
    expect("#{ resource_group_name }#{ resource_name }#{ action_name }#{ transactional_example_name }#{ response_name }")
      .to eql(full_string_name)
  }
)

# Configure Vigia to run spec/example.apib
Vigia.configure do |config|
  config.host        = Vigia::ExampleApp.host
  config.source_file = Vigia::ExampleTest.apib_path
  # config.custom_examples_paths = File.join(__dir__, '../', 'support', 'shared_examples', 'my_custom_examples')

  config.before_group do
    group_name = described_class.described_object.name
    let("#{ described_class.group.name }_name") { group_name }
  end

  config.after_group do
    group_name = described_class.described_object.name

    it 'has the described object name defined' do
      expect(group_name).to eql(described_class.described_object.name)
    end
  end

  config.before_context do
    let(:full_string_name) do
      "#{ resource_group.name }#{ resource.name }#{ action.name }#{ transactional_example.name }#{ response.name }"
    end
  end

  config.after_context do
    it 'has all the properties defined after the example' do
      expect(http_client_options).to be_a(Object)
      expect(expectations).to be_a(OpenStruct)
      expect(result).to be_a(OpenStruct)
    end
  end
end

# Run Vigia within RSpec process
load File.join(Vigia.spec_folder, 'api_spec.rb')
