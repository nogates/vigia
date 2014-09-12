require 'celluloid/autostart'
require 'sinatra/base'
require 'json'

module SpecApib

  # Execute Sinatra App in background
  class ExampleServer
    include Celluloid

    def start!
      ExampleApp.run!
    end
  end

  # ExampleApp based on Sinatra framework
  class ExampleApp < Sinatra::Base
    get '/scenarios' do
      status 200
      content_type 'application/vnd.siren+json; charset=utf-8'
      SpecApib::ExampleFixtures['/scenarios']
    end
    post '/scenarios' do
      status 201
      content_type 'application/vnd.siren+json; charset=utf-8'
      SpecApib::ExampleFixtures['/scenarios_create']
    end
    get '/scenarios/:scenario_slug' do
      status 200
      content_type 'application/vnd.siren+json; charset=utf-8'
      SpecApib::ExampleFixtures['/scenarios/scenario_one']
    end
    get '/scenarios/:scenario_slug/steps' do
      status 200
      content_type 'application/vnd.siren+json; charset=utf-8'
      SpecApib::ExampleFixtures['/scenarios/steps']
    end
    post '/scenarios/:scenario_slug/steps' do
      status 201
      content_type 'application/vnd.siren+json; charset=utf-8'
      SpecApib::ExampleFixtures['/scenarios/steps_create']
    end
    put '/scenarios/:scenario_slug/steps/:id' do
      status 201
      content_type 'application/vnd.siren+json; charset=utf-8'
      SpecApib::ExampleFixtures['/scenarios/steps_update']
    end
    delete '/scenarios/:scenario_slug/steps/:id' do
      status 204
      content_type 'application/vnd.siren+json; charset=utf-8'
      SpecApib::ExampleFixtures['/scenarios/steps_delete']
    end

    def self.host
      bind_address = running_server.config[:BindAddress]
      port         = running_server.config[:Port]
      "http://#{ bind_address }:#{ port }"
    end
  end


  class ExampleFixtures
    class << self

      def [] key
        case key
        when '/scenarios'
          scenarios_resource_collection_get_action.responses.first.body
        when '/scenarios_create'
          scenarios_resource_collection_post_action.responses.first.body
        when '/scenarios/scenario_one'
          scenarios_resource_item_get_action.responses.first.body
        when '/scenarios/steps'
          steps_resource_collection_get_action.responses.first.body
        when '/scenarios/steps_create'
          steps_resource_collection_post_action.responses.first.body
        when '/scenarios/steps_update'
          steps_resource_item_put_action.responses.first.body
        when '/scenarios/steps_delete'
          steps_resource_item_delete_action.responses.first.body
        else
          raise('Invalid Fixture')
        end
      end

      def steps_resource_item_put_action
        steps_resource_item.actions.first.examples.first
      end

      def steps_resource_item_delete_action
        steps_resource_item.actions.last.examples.first
      end

      def steps_resource_collection_get_action
        steps_resource_collection.actions.first.examples.first
      end

      def steps_resource_collection_post_action
        steps_resource_collection.actions.last.examples.first
      end

      def scenarios_resource_item_get_action
        scenarios_resource_item.actions.first.examples.first
      end

      def scenarios_resource_collection_post_action
        scenarios_resource_collection.actions.last.examples.first
      end

      def scenarios_resource_collection_get_action
        scenarios_resource_collection.actions.first.examples.first
      end

      def steps_resource_collection
        steps_resource.resources.first
      end

      def steps_resource_item
        steps_resource.resources.last
      end

      def scenarios_resource_collection
        scenarios_resource.resources.first
      end

      def scenarios_resource_item
        scenarios_resource.resources.last
      end

      def steps_resource
        SpecApib::ExampleTest.apib.ast.resource_groups.last
      end
      def scenarios_resource
        SpecApib::ExampleTest.apib.ast.resource_groups.first
      end
    end
  end
end

