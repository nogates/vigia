SpecApib
========

# What is it?

SpecApib is a gem to perform integration test within RSpec framework.

# Installation

Include SpecApib as gem inside `:test` group

```ruby

group :test do
  gem 'specapib', github: 'nogates/specapib', branch: 'wip'
end

```

Run bundle install

```
$ bundle install
```

SpecApin can now be used inside your application.

# Configuration

SpecApib provides an easy way to configure the parameters of the test

```ruby

SpecApib.configure do |config|

  # Define the Apib Blueprint Path
  config.apib_path = "#{ Rails.root }/apibs/my_api.apib"

  # Define the host address where the request will be performed.
  config.host = 'http://localhost:3000'

  # Include examples files within the Rspec.
  config.custom_examples_paths = [ "#{ Rails.root }/spec/apibs" ]

  # Add custom examples for the apib.
  # config.add_custom_examples_on(:all, 'my custom examples')

  # Includes a collection of custom headers in the requests.
  # config.headers = {}
end

```

## Putting all together: using a rake task to perform the tests

This example shows an easy way to start a rails server an perform you apibs test.

```ruby
# Your lib/tasks/specapib.rake

namespace :spec do

  desc 'Run SpecApib tests'
  task :specapib => :environment do

    system("bundle exec rails s -e #{ Rails.env } -d")
    sleep 10 # give some time to the server to start

    SpecApib.configure do |config|
      config.apib_path = "#{ Rails.root }/apibs/my_api.apib"
      config.host = 'http://localhost:3000'
    end

    SpecApib.rspec!

  end
end
```
