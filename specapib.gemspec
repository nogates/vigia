# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'specapib/version'

Gem::Specification.new do |spec|
  spec.name          = 'specapib'
  spec.version       = SpecApib::VERSION
  spec.authors       = ['atlas2ninjas']
  spec.email         = ['atlas2ninjas@lonelyplanet.com.au']
  spec.summary       = %q{Test your Apiary Blueprint specification on ruby}
  spec.description   = %q{Test your Apiary Blueprint specification on ruby}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = Dir['Gemfile', 'Rakefile', 'lib/tasks/specapib.rake', 'lib/**/*.rb', '*.md']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_runtime_dependency 'rake'

  spec.add_dependency 'redsnow', '~> 0.1.3'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'rspec'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry-debugger'
end

