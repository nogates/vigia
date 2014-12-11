# require 'siren'
#
# module Vigia
#   class Siren
#     class << self
#       def links_are_valid?(siren_response, vigia_rspec)
#         new(siren_response, vigia_rspec).links_are_valid?
#       end
#       def actions_are_valid?(siren_response, vigia_rspec)
#         new(siren_response, vigia_rspec).actions_are_valid?
#       end
#     end
#
#     attr_reader :vigia_rspec
#
#     def initialize(siren_response, vigia_rspec)
#       @vigia_rspec    = vigia_rspec
#       @siren_response = ::Siren.parse(siren_response)
#     end
#
#     def links_are_valid?
#       links.each do |link|
#         vigia_rspec.expect(link_is_valid?(link)).to vigia_rspec.be(true)
#       end
#     end
#
#     def actions_are_valid?
#       actions.each do |action|
#         vigia_rspec.expect { action_is_valid?(action) }.not_to vigia_rspec.raise_error
#       end
#     end
#
#     def link_is_valid?(link)
#       href = URI(link['href'])
#       # We don validate external links
#       return true unless vigia_rspec.adapter.host == "#{ href.scheme }://#{ href.host }/"
#       vigia_rspec.adapter.action_exists?('GET', href.request_uri)
#     end
#
#     def action_is_valid?(action)
#       action_uri =  URI(action['href'])
#       # We don't validate the action at all if it matches the resource we are in.
#       return true if vigia_rspec.http_client_options.url == action_uri.request_uri
#       adapter_action = vigia_rspec.adapter.action_by(action['method'], action_uri.request_uri)
#
#       raise "Adapter does not provide an action with url `#{ action['href'] }`" unless adapter_action
#       raise "Invalid action fieds `#{  }`" if false
#
#   #     binding.pry
#
#       false
#     # We don't validate the action at all if it matches the resource we are in.
#     end
#
#     def links
#       @siren_response['links'] || []
#     end
#
#     def actions
#       @siren_response['actions'] || []
#     end
#   end
# end
#
# # shared_examples 'siren actions match blueprint spec' do
# #   it 'has actions that match a blueprint action' do
# #     link_path = JsonPath.new('$..actions')
# #     link_path[response.body].each do |actions|
# #       actions.each do |action|
# #         request_uri = URI(action['href']).request_uri
# #         # We don't validate the action at all if it matches the resource we are in.
# #         next if subject.action.resource.matches? request_uri
# #
# #         resource = subject.parser.get_resource(action['name'])
# #         expect(resource).to_not be_nil, -> { "Invalid Resource: #{ action['name'] }" }
# #         matched_actions = resource.actions.select do |apib_action|
# #           apib_action if apib_action.method == action['method'].downcase
# #         end
# #         expect(matched_actions.length).to eq(1), lambda {
# #           "Resource #{ action['name'] } has no actions of method: #{action['method'] }"
# #         }
# #
# #         expect(resource.matches? request_uri).to be_truthy, lambda {
# #           <<-FORMATTED_ERROR
# #             Resource URI does not match Action URL
# #             Resource URI: #{ resource.uri.pattern }
# #             Action URL: #{ request_uri }
# #           FORMATTED_ERROR
# #         }
# #         # Check that the matched blueprint action has the parameters used in the siren action
# #         expect(matched_actions.first.parameters.map(&:name))
# #           .to include(*action['fields'].map { |field| field['name'] })
# #       end
# #     end if response.body.present?
# #   end
# # end
#
# # Vigia::Sail::Context.register(
# #   :siren_action,
# #   disable_if: -> { response.body.nil? || response.body.empty? },
# #   in_contexts: [ :default ],
# #   examples:    [ ],
# #   before_context: -> {
# #     siren           = ::Siren.parse(described_class.described_object.body)
# #     action_contexts = [ *siren["actions"] ].each_with_object([]) do |action, actions|
# #       action_name    = "#{ name }_#{ action['name'] }".to_sym
# #       action_headers = {}
# #       action_headers.merge!(content_type: action['type']) if action['type']
# #       action_payload = [ *action[:fields] ].compact.each_with_object({}) do |field, hash|
# #         hash.merge!(field['name'] => field['value'])
# #       end.to_json
# #       context_config = {
# #         examples: [ :code_match ],
# #         description: "Siren Action #{ action['name'] }",
# #          http_client_options: {
# #             headers: action_headers,
# #             method:  action['method'],
# #             url:     action['href'],
# #             payload: "#{ action_payload.to_json unless action_payload.empty? }",
# #          },
# #         expectations: {
# #           code: (200..299),
# #         }
# #       }
# #       Vigia::Sail::Context.register(action_name, context_config)
# #       actions << action_name
# #     end
# #     context_siren_action.options[:contexts] = action_contexts
# #   }
# # )
#
# # Vigia::Sail::Example.register(
# #   :links_match_blueprint_spec,
# #   description: 'Siren links matches adapter resources',
# #   expectation: -> { Vigia::Siren.links_are_valid?(response.body, self) },
# #   content_type: 'application/siren+json',
# #   disable_if: -> { response.body.nil? || response.body.empty? }
# # )
#
#
# # Vigia::Sail::Example.register(
# #   :actions_match_blueprint_spec,
# #   description: 'Siren actions matches adapter resources',
# #   expectation: -> { Vigia::Siren.actions_are_valid?(response.body, self) },
# #   content_type: 'application/siren+json',
# #   disable_if: -> { response.body.nil? || response.body.empty? }
# # )
#
