require 'specapib'
require 'pry'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f}

def example_apib
  RedSnow::parse example_apib_source
end

def example_apib_source
  File.read example_apib_path
end

def example_apib_path
  File.join __dir__, 'example.apib'
end