Vigia
========

# What is it?

Vigia is a gem to perform integration test within RSpec framework using a compatible
[Api Blueprint](https://github.com/apiaryio/api-blueprint/blob/master/API%20Blueprint%20Specification.md) definition file. It uses [RedSnow]() to parse the Api Blueprint file and RestClient as http client to perform the requests.

Vigia runs by default only two comparision between the blueprint file and the server response. The Http response code and the inclusion of the blueprint headers inside the headers response.


# Installation

Include Vigia as gem inside `:test` group

```ruby

group :test do
  gem 'vigia', github: 'nogates/vigia', branch: 'wip'
end

```

Run bundle install

```
$ bundle install
```

Vigia can now be used inside your application.

# Getting started

Vigia provides an easy way to configure the parameters of the test

```ruby

Vigia.configure do |config|

  # Define the Apib Blueprint Path
  config.apib_path = "#{ Rails.root }/apibs/my_api.apib"

  # Define the host address where the request will be performed.
  config.host = 'http://localhost:3000'

  # Include examples files within the Rspec.
  config.custom_examples_paths = [ "#{ Rails.root }/spec/apibs" ]

  # Add custom examples for the apib.
  config.add_custom_examples_on(:all, 'my custom examples')

  # Includes a collection of custom headers in all the requests.
  config.headers = { authorization: 'Bearer <your hash here>' }

end

```

## Putting all together: using a rake task to perform the tests

This example shows an easy way to start a rails server an perform you apibs test.

```ruby
# Your lib/tasks/vigia.rake

namespace :spec do

  desc 'Run Vigia tests'
  task :vigia => :environment do

    # start rails server by the easiest way
    system("bundle exec rails s -e #{ Rails.env } -d")
    # give some time to the server
    sleep 10

    Vigia.configure do |config|
      config.apib_path = "#{ Rails.root }/apibs/my_api.apib"
      config.host = 'http://localhost:3000'
    end

    Vigia.rspec!

  end
end
```

## Custom examples

Vigia allows to include custom rspec examples in the test using some options in the config

```ruby

Vigia.configure do |config|
  # Define where your examples are located
  config.custom_examples_paths = [ '/my_project/shared_examples/apib_examples.rb' ]

  # Define the custom examples you want to include in your test

  # To the example in all your request use `:all` symbol
  config.add_custom_examples_on(:all, 'my custom examples')

  # You can specify the name of an action or a resource. Only the requests which belong to that
  # resource or action will run these shared examples
  config.add_custom_examples_on('Create an Image', 'create image examples')

end
```

Then, create your Rspec shared example and name the examples accordingly

```ruby
# /my_project/shared_examples/apib_examples.rb

shared_examples 'my custom examples' do |vigia_example, response|
  it 'is a valid json response' do
    expect { JSON.parse(result[:body]) }.not_to raise_error
  end
end

shared_examples 'create image examples' do |vigia_example, response|
  before do
    @json_result = JSON.parse(result[:body])
    @json_expectation = JSON.parse(expectations[:body])
  end

  it 'has the expected link to the image' do |vigia_example, response|
    expect(@json_result['image']['link']).to eql(@json_expectation['image']['link'])
  end
end
```

# ToDo

 - [ ] Vigia::Example defines each Api Blueprint transactional example, but each example can have several responses (200, 404, etc.). Think a better way to handle this instead of passing the response variable across methods.

 - [ ] Spike: Do we need to set RSpec specific options? (Vigia::Rspec)

 - [ ] Parse http client exceptions properly. (done?)

 - [ ] Support custom http client through config. (low priority)

