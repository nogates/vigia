require 'simplecov'

# Cucumber + Rspec should cover 100% of the gem
SimpleCov.minimum_coverage 100

require 'vigia'
require 'pry'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
