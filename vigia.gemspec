# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vigia/version'

Gem::Specification.new do |spec|
  spec.name          = 'vigia'
  spec.version       = Vigia::VERSION
  spec.authors       = ['David Tapiador', 'atlas2ninjas']
  spec.email         = ['david.tapiador@lonelyplanet.com.au',
                        'atlas2ninjas@lonelyplanet.com.au']
  spec.summary       = %q{Test your Apiary Blueprint specification on ruby}
  spec.description   = %q{Test your Apiary Blueprint specification on ruby}
  spec.homepage      = 'https://github.com/nogates/vigia'
  spec.license       = 'MIT'

  spec.files         = Dir['Rakefile', 'Gemfile', 'lib/**/*.rb', '*.md']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_runtime_dependency 'rake'

  spec.add_dependency 'redsnow'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'rspec'
  spec.add_dependency 'addressable'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'sinatra'
  spec.add_development_dependency 'celluloid'
  spec.add_development_dependency 'json'
  spec.add_development_dependency 'pry-debugger'
  spec.add_development_dependency 'simplecov'
end

