Vigia
========

[![Build Status](https://travis-ci.org/lonelyplanet/vigia.svg?branch=master)](https://travis-ci.org/lonelyplanet/vigia)
[![Code Climate](https://codeclimate.com/github/nogates/vigia/badges/gpa.svg)](https://codeclimate.com/github/nogates/vigia)
[![Test Coverage](https://codeclimate.com/github/nogates/vigia/badges/coverage.svg)](https://codeclimate.com/github/nogates/vigia)

# What is it?

<img src="http://singularities.org/vigia.png" width="96" height="96" class="right" alt="Vigia logo" />

Vigia is a gem to perform integration tests on an API server using RSpec and a compatible adapter. The adapter creates the structure of the test (groups and context) and sets up all the variables (See [Context variables](https://github.com/lonelyplanet/vigia/wiki/Context-variables)) used to perform the http request.

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

# Adapters

Currently, Vigia supports [API Blueprint](https://apiblueprint.org/) and [RAML](http://raml.org/) definition files. By default, Vigia uses the Blueprint Adapter. To configure Vigia to use the RAML adapter, just pass the `adapter` class to the config block

```ruby

Vigia.configure do |config|
  config.adapter     = Vigia::Adapters::Raml
  config.source_file = 'my_api_definition.raml'
  # extra config
end
```

(See [Adapters](https://github.com/lonelyplanet/vigia/wiki/Adapters)) to see more information about custom adapters.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See [LICENSE](https://raw.githubusercontent.com/lonelyplanet/vigia/master/LICENSE).



