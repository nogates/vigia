Vigia
========

[![Build Status](https://travis-ci.org/nogates/vigia.svg?branch=master)](https://travis-ci.org/nogates/vigia)
[![Code Climate](https://codeclimate.com/github/nogates/vigia/badges/gpa.svg)](https://codeclimate.com/github/nogates/vigia)
[![Test Coverage](https://codeclimate.com/github/nogates/vigia/badges/coverage.svg)](https://codeclimate.com/github/nogates/vigia)

# What is it?

<img src="http://singularities.org/vigia.png" width="96" height="96" class="right" alt="Vigia logo" />

Vigia is a gem to perform integration tests using RSpec and a compatible adapter (See [Adapters](#adapters)). The adapter creates the structure of the test (groups and context) and sets up all the variables (See [Context variables](#context-variables)) used to perform the http request.

These results and expectations objects can be used to run examples that will compare the expected value with the server response value. Vigia allows to use a variety of different ways to execute these comparisons (See [Vigia Examples](#vigia-examples) and [Custom Shared Examples](#custom-shared-examples))

# Installation

Include Vigia as gem inside `:test` group

```ruby

group :test do
  gem 'vigia'
end

```

Run bundle install

```bash
$ bundle install
```

Now, Vigia can be used inside your application.

# Getting started

This example shows an easy way to start a rails server and perform you apibs test.

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
      config.source_file = "#{ Rails.root }/apibs/my_api.apib"
      config.host        = 'http://localhost:3000'
    end

    Vigia.rspec!
  end
end
```

## Configuration

Vigia tries to be flexible enough in case that you need to run custom operations during the tests.

```ruby

Vigia.configure do |config|

  # Define your source file. For example, within a Rails app
  config.source_file = "#{ Rails.root }/apibs/my_api.apib"

  # Define the host address where the request will be performed.
  config.host = 'http://localhost:3000'

  # Include a collection of custom headers in all the requests.
  config.headers = { authorization: 'Bearer <your hash here>' }

  # Reset rspec_config and set up documentation formatter
  config.rspec_config do |rspec_config|
    rspec_config.reset
    rspec_config.formatter = RSpec::Core::Formatters::DocumentationFormatter
  end

  # Attach a before_context hook to set up the database using Databasecleaner
  config.before_context do
    DatabaseCleaner.start
  end

  # Set a timer on the primary group and raise an exception if the
  # described group takes more than 5 seconds to run
  config.before_group do
    let!(:group_started_at) { Time.now } if described_class.options[:primary]
  end

  config.after_group do
    if described_class.options[:primary]
      it 'has taken less than 5 seconds to run this example' do
        expect(Time.now.to_i - group_started_at.to_i).to be < 5
      end
    end
  end
end

Vigia.rspec!

```
For more information about config, see the `Vigia::Config` class.

## Adapters

By default, Vigia uses `Vigia::Adapters::Blueprint` adapter. This adapter takes an Api Blueprint compatible file and parses it using [RedSnow](https://github.com/apiaryio/redsnow). Then, it builds up the test structure accordingly.

If needed, Vigia can be configured to use a custom adapter. To do so, you just need to specify the adapter class inside the vigia configuration block:

```ruby
Vigia.configure do |config|
  config.adapter = MyBlogAdapter
end
```

Then, insde your adapter class, you can use the `setup_adater` method to define the groups and contexts that the adapter will provide:

```ruby

# Post
class MyBlogAdapter < Vigia::Adapter
  setup_adapter do
    group :resource,
      primary: true,
      contexts: [ :default ]
      describes: [ :post, :pages ]

    context :default,
      http_client_options: {
        url: -> { "/#{ resource }" },
        method: :get
        },
      expectations: {
        code: 200,
        headers: {},
        body: -> { adapter.body_for(resource) }
      }
  end

  def body_for(resource)
    case resource
    when :post
      # Your post index expected body
    when :pages
      # Your pages index expected body
    else
      'Unknown resource. WTH!'
    end
  end
end
```

When vigia starts, it fetchs the first group defined as primary. For each group, Vigia will loop on each element of the describes option (`:post, :page` in this example), and will set a rspec memoized object named as the group (`let(:resource) { :post }`). Then, it will run the children (if any) and the contexts in this group, setting up the `http_client_options` and `expectations` memoized objects per context.

See `Vigia::Adapters::Blueprint` class for more information about configuring and setting up an adapter.

## Context Variables

Vigia tries to be consistent with the way the RSpec are normally written. It creates the describe groups and context based on the adapter configuration and set up all the variables for the examples by using RSpec memoized objects.

```ruby

# With an adapter `ExampleAdapter` with this config
#
# group :resource,
#   describes: [ :posts, :pages ],
#   children:  [ :action ]
#
# group :action
#   describes: [ :get, :post ],
#   context:   [ :default ]
#
# context :default,
#   http_client_options: {
#     method:  -> { action.to_s.upcase }
#     url:     -> { adapter.url_for(resource) }" }
#     headers: :headers
#   expectations:
#     code: :code
#     headers: {}
#     body: -> { Body.for(resource} }
#
# Vigia will generate this RSpec code

describe Vigia::RSpec do
  let(:adapter) { ExampleAdapter.instance }
  let(:client)  { Vigia.config.http_client_class.new(http_options) }
  let(:result)  { client.run }

  # the loop starts...
  describe 'posts' do
    let(:resource) { :posts }

    describe 'action' do
      let(:action) { :get }

      context 'default' do
        let(:http_client_options) { Vigia::HttpClient::Options.new(context_options) }
        let(:expectations)        { Vigia::HttpClient::ExpectedRequest.new(expectations) }

        # EXAMPLES RUN HERE!
      end
      # NEXT ACTION
    end
    # NEXT RESOURCE
  end
end
```

Also, It is important to mention that it is in this context where the adapter configuration will be executed. In the previous example, we configured the http_client option as follows:

```ruby
#   http_client_options: {
#     method:  -> { action.to_s.upcase }
#     url:     -> { adapter.url_for(resource) }" }
#     headers: :headers
```

The option `method` is a lambda object. This object will be executed inside the RSpec memoized objects context. It is the same as doing:

```ruby
  # it has access to all context/group memoized objects
  let(:method) { action.to_s.upcase }
```

You can also use the adapter like in option `url`, since it has been defined as a memoized object by Vigia::RSpec.

Lastly, you can specify a symbol as the option value. In this case, the adapter will be the reciever of this method.

## Vigia Examples

The first way to include examples on vigia is using `register`. Option `disabled_if` can be used to prevent the example for being executed on different situations. `contexts` limits the example to the listed contexts.

```ruby

# On your config file, spec_helper, etc.
Vigia::Sail::Example.register(
  :my_custom_body_validator,
  expectation: -> { expect { MyValidator(result.body) }.not.to raise_error } },
  contexts:    [ :my_context ],  # default: :default
  disable_if:  -> { ! result.headers[:content_type].include?('my_validator_mime') }
  )
```

## Custom shared examples

Vigia allows to include custom shared rspec examples in the test using some options in the config

```ruby

Vigia.configure do |config|
  # Define where your examples are located
  config.custom_examples_paths = [ '/my_project/shared_examples/apib_examples.rb' ]

  # Define the custom examples you want to include in your test

  # To the example in all your requests use `:all` symbol
  config.add_custom_examples_on(:all, 'my custom examples')
end
```

Then, create your Rspec shared example and name the examples accordingly

```ruby
# /my_project/shared_examples/apib_examples.rb

shared_examples 'my custom examples' do |vigia_example, response|
  it 'is a valid json response' do
    expect { JSON.parse(result.body) }.not_to raise_error
  end
end

```
