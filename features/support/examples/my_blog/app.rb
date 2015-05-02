require 'sinatra/base'
require 'json'

module Vigia
  module Examples
    class MyBlog
      class App < Sinatra::Base

        set :server, 'webrick'

        before do
          content_type 'application/json'
        end

        get '/posts' do
          status 200
          Vigia::Examples::MyBlog::Data['/posts'].to_json
        end
        post '/posts' do
          status 201
          Vigia::Examples::MyBlog::Data['/post_create'].to_json
        end
        get '/posts/:post_slug' do
          status 200
          Vigia::Examples::MyBlog::Data['/posts/post_1'].to_json
        end
        get '/posts/:post_slug/comments' do
          status 200
          Vigia::Examples::MyBlog::Data['/posts/1/comments'].to_json
        end
        post '/posts/:post_slug/comments' do
          status 201
          Vigia::Examples::MyBlog::Data['/posts/1/comment_create'].to_json
        end
        put '/posts/:post_slug/comments/:id' do
          status 201
          Vigia::Examples::MyBlog::Data['/posts/1/comment_update'].to_json
        end
        delete '/posts/:post_slug/comments/:id' do
          status 204
          nil
        end

        def self.host
          bind_address = running_server.config[:BindAddress]
          port         = running_server.config[:Port]
          "http://#{ bind_address }:#{ port }"
        end

        def self.server_settings
           { AccessLog: Logger.new, Logger: Logger.new }
        end
      end
    end
    class Logger
      (::Logger.instance_methods - Object.instance_methods).each do |logger_instance_method|
        define_method(logger_instance_method) { |*args| }
      end
    end
  end
end
