shared_examples "redsnow doubles" do

  let(:resource) do
    instance_double(
      RedSnow::Resource,
      name: resource_name,
      description: resource_description,
      parameters: resource_parameters,
      uri_template: resource_uri_template,
      model: resource_model
    )
  end

  let(:resource_name) do
    'My resource name'
  end

  let(:resource_description) do
    'My resource description'
  end

  let(:resource_uri_template) do
    '/scenarios/example'
  end

  let(:resource_model) do
    instance_double(
      RedSnow::Payload,
      headers: resource_model_headers
    )
  end

  let(:resource_model_headers) do
    instance_double(
      RedSnow::Headers,
      collection: resource_model_headers_collection
    )
  end


  let(:resource_model_headers_collection) do
    [ {name: 'Resource-Model-Header', value: 'A Resource Model Header' } ]
  end

  let(:resource_parameters) do
    instance_double(
      RedSnow::Parameters,
      collection: [resource_parameter_one]
    )
  end

  let(:resource_parameter_one) do
    instance_double(
      RedSnow::Parameter,
      name: resource_parameter_one_name,
      example_value: resource_parameter_one_example_value
    )
  end

  let(:resource_parameter_one_name) do
    'scenario_slug'
  end

  let(:resource_parameter_one_example_value) do
    'scenario_one'
  end

  let(:response) do
    instance_double(
      RedSnow::Payload,
      name: expected_response_name,
      body: expected_response_body,
      headers: response_headers
    )
  end

  let(:expected_response_name) do
    'The example response name'
  end

  let(:expected_response_body) do
    'The example response body'
  end

  let(:response_headers) do
    instance_double(
      RedSnow::Headers,
      collection: response_headers_collection
    )
  end

  let(:response_headers_collection) do
    [ {name: 'Response-Header', value: 'A Response Header' } ]
  end

  let(:payload) do
    instance_double(
      RedSnow::Payload,
      name: payload_name,
      body: payload_body,
      headers: payload_headers
    )
  end

  let(:payload_name) do
    '100'
  end

  let(:payload_body) do
    'Payload body'
  end

  let(:payload_headers) do
    instance_double(
      RedSnow::Headers,
      collection: payload_headers_collection
    )
  end

  let(:payload_headers_collection) do
    [ {name: 'Payload-Header', value: 'A Payload Header' } ]
  end

  let(:action) do
    instance_double(
      RedSnow::Action,
      name: action_name,
      description: action_description,
      parameters: action_parameters
    )
  end

  let(:action_name) do
    'My action name'
  end

  let(:action_description) do
    'My action description'
  end

  let(:action_parameters) do
    instance_double(
      RedSnow::Parameters,
      collection: [action_parameter_one]
    )
  end

  let(:action_parameter_one) do
    instance_double(
      RedSnow::Parameter,
      name: action_parameter_one_name,
      example_value: action_parameter_one_example_value
    )
  end

  let(:action_parameter_one_name) do
    'page'
  end

  let(:action_parameter_one_example_value) do
    '3'
  end

  let(:apib_example) do
    instance_double(RedSnow::TransactionExample)
  end
end
