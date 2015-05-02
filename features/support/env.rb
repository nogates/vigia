require 'simplecov'
require 'pry'
require 'vigia'

Before('@my_blog') do
  @running_apps ||= {}
  unless @running_apps.has_key?('my_blog')
    my_blog = Vigia::Examples::MyBlog.new
    my_blog.start_server
    @running_apps['my_blog'] = my_blog
  end
end

RSpec::Matchers.define :match_vigia_output do |output|
  match do
    include(*output.lines.to_a).matches?(actual.lines.to_a)
  end
  failure_message do
    lines = (output.lines.to_a - actual.lines.to_a).join
    "Could not find lines: \n #{ lines } \in: \n #{ actual }\n"
  end
end

