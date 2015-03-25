Vigia
========

[![Build Status](https://travis-ci.org/lonelyplanet/vigia.svg?branch=master)](https://travis-ci.org/lonelyplanet/vigia)
[![Code Climate](https://codeclimate.com/github/nogates/vigia/badges/gpa.svg)](https://codeclimate.com/github/nogates/vigia)
[![Test Coverage](https://codeclimate.com/github/nogates/vigia/badges/coverage.svg)](https://codeclimate.com/github/nogates/vigia)

# What is it?

<img src="http://singularities.org/vigia.png" width="96" height="96" class="right" alt="Vigia logo" />

Vigia is a gem to perform integration tests using RSpec and a compatible adapter (See [Adapters](https://github.com/lonelyplanet/vigia/wiki/Adapters)). The adapter creates the structure of the test (groups and context) and sets up all the variables (See [Context variables](https://github.com/lonelyplanet/vigia/wiki/Context-variables)) used to perform the http request.

These results and expectations objects can be used to run examples that will compare the expected value with the server response value. Vigia allows to use a variety of different ways to execute these comparisons (See [Vigia Examples](https://github.com/lonelyplanet/vigia/wiki/Expectations---Examples) and [Custom Shared Examples](https://github.com/lonelyplanet/vigia/wiki/Shared-examples))

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

