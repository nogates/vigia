# encoding: utf-8

def description_for object
  case object
  when RedSnow::ResourceGroup
    "Resource Group: #{ object.name }"
  when RedSnow::Resource
    "Resource: #{ object.name } (#{ object.uri_template })"
  when RedSnow::Action
    "Action: #{ object.name } (#{ object.method })"
  when RedSnow::Payload
    "Response: #{ object.name }"
  end
end

def format_error(result, expectation)
  <<-FORMATTED_ERROR 

  Expected:

    #{ expectation.inspect }

  Got:

    #{ result.inspect }


  FORMATTED_ERROR
end
