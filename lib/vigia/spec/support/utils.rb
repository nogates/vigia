# encoding: utf-8

def format_error(result, expectation)
  <<-FORMATTED_ERROR

  Expected:

    #{ expectation.inspect }

  Got:

    #{ result.inspect }


  FORMATTED_ERROR
end
