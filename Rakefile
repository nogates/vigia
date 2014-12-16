require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = '--tags ~@wip'
end

RSpec::Core::RakeTask.new(:spec)

desc 'Clear tmp folders'
task :clobber do
  FileUtils.rm_rf(File.join(__dir__, 'coverage'))
end

# Not sure why simplecov is preventing cucumber for being run after spec
# when running rake default. That is why I am using commands to execute them
task :default do
  raise 'Cucumber Failed' unless system('bundle exec rake cucumber')
  raise 'RSpec Failed'    unless system('bundle exec rake spec')
end

