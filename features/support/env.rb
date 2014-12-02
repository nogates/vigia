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

