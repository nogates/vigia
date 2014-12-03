@wip
Feature: Example Apib
  Running the whole example apib with a sinatra server

Scenario: Placing a matching GET request
  Given I start "example server"
  When the server "example server" is ready
  Then I configure Vigia with the following options:
    | source_file      | example.apib          |
    | host             | http://localhost:3000 |
  Then I run Vigia
  And the output should contain the following:
    """

    Vigia::Rspec
      Resource Group: Scenarios 1
        Resource: 1.1 Scenarios
          GET
            Example #0
              Running Response 200
                context default
                  has the expected HTTP code
                  includes the expected headers
          POST
            Example #0
              Running Response 201
                context default
                  has the expected HTTP code
                  includes the expected headers
        Resource: 1.2 Scenario
          GET
            Example #0
              Running Response 200
                context default
                  has the expected HTTP code
                  includes the expected headers
      Resource Group: 2 Steps
        Resource: 2.1 Steps
          GET
            Example #0
              Running Response 200
                context default
                  has the expected HTTP code
                  includes the expected headers
          POST
            Example #0
              Running Response 201
                context default
                  has the expected HTTP code
                  includes the expected headers
        Resource: 2.2 Step
          PUT
            Example #0
              Running Response 201
                context default
                  has the expected HTTP code
                  includes the expected headers
          DELETE
            Example #0
              Running Response 204
                context default
                  has the expected HTTP code
                  includes the expected headers

    """
  And the total tests line should equal "14 examples, 0 failures"
  And the error output should be empty

