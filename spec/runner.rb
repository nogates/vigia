require 'spec_helper'

Vigia.configure do |config|
  config.source_file = File.join(__dir__, '../features/support/examples/my_blog/my_blog.raml')
  config.adapter     = Vigia::Adapters::Raml
  config.host        = 'http://localhost:3000'
  config.rspec_config do |rspec_config|
    rspec_config.reset
#     rspec_config.dry_run   = true
    rspec_config.formatter = RSpec::Core::Formatters::DocumentationFormatter
  end
end

Vigia.rspec!
