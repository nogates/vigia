require 'simplecov'

# Cucumber + Rspec should cover 100% of the gem
SimpleCov.minimum_coverage 100

require 'pry'
require 'vigia'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
