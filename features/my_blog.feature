@my_blog
Feature: My Blog
  Test My blog definition using a sinatra server

Scenario: Using the blueprint adapter
  Given the server for "my_blog" app is ready
  Then I configure Vigia with the following options:
    | source_file      | my_blog/my_blog.apib   |
    | host             | my_blog.host           |
  Then I run Vigia
  And the output should contain the following:
    """

    Vigia::Rspec
      Resource Group: Posts
        Resource: Posts
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
        Resource: 1.2 Post
          GET
            Example #0
              Running Response 200
                context default
                  has the expected HTTP code
                  includes the expected headers
      Resource Group: Comments
        Resource: Comments
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
        Resource: 2.2 Comment
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

Scenario: Using the blueprint adapter with hooks
  Given the server for "my_blog" app is ready
  Then I configure Vigia with the following options:
    | source_file      | my_blog/my_blog.apib   |
    | host             | my_blog.host           |
  Then I configure a "before_group" hook with this block:
    """
      group_name = described_class.described_object.name
      let("#{ described_class.group.name }_name") { group_name }
    """
  Then I configure a "after_group" hook with this block:
    """
      group_name = described_class.described_object.name

      it 'has the described object name defined' do
        expect(group_name).to eql(described_class.described_object.name)
      end
    """
  Then I configure a "before_context" hook with this block:
    """
      let(:full_string_name) do
        "#{ resource_group.name }#{ resource.name }#{ action.name }#{ transactional_example.name }#{ response.name }"
      end
    """
  Then I configure a "after_context" hook with this block:
    """
      it 'has all the properties defined after the example' do
        expect(http_client_options).to be_a(Object)
        expect(expectations).to be_a(OpenStruct)
        expect(result).to be_a(OpenStruct)
      end
    """
  Then I run Vigia
  And the output should contain the following:
    """

    Vigia::Rspec
      Resource Group: Posts
        has the described object name defined
        Resource: Posts
          has the described object name defined
          GET
            has the described object name defined
            Example #0
              has the described object name defined
              Running Response 200
                has the described object name defined
                context default
                  has the expected HTTP code
                  includes the expected headers
                  has all the properties defined after the example
          POST
            has the described object name defined
            Example #0
              has the described object name defined
              Running Response 201
                has the described object name defined
                context default
                  has the expected HTTP code
                  includes the expected headers
                  has all the properties defined after the example
        Resource: 1.2 Post
          has the described object name defined
          GET
            has the described object name defined
            Example #0
              has the described object name defined
              Running Response 200
                has the described object name defined
                context default
                  has the expected HTTP code
                  includes the expected headers
                  has all the properties defined after the example
      Resource Group: Comments
        has the described object name defined
        Resource: Comments
          has the described object name defined
          GET
            has the described object name defined
            Example #0
              has the described object name defined
              Running Response 200
                has the described object name defined
                context default
                  has the expected HTTP code
                  includes the expected headers
                  has all the properties defined after the example
          POST
            has the described object name defined
            Example #0
              has the described object name defined
              Running Response 201
                has the described object name defined
                context default
                  has the expected HTTP code
                  includes the expected headers
                  has all the properties defined after the example
        Resource: 2.2 Comment
          has the described object name defined
          PUT
            has the described object name defined
            Example #0
              has the described object name defined
              Running Response 201
                has the described object name defined
                context default
                  has the expected HTTP code
                  includes the expected headers
                  has all the properties defined after the example
          DELETE
            has the described object name defined
            Example #0
              has the described object name defined
              Running Response 204
                has the described object name defined
                context default
                  has the expected HTTP code
                  includes the expected headers
                  has all the properties defined after the example

    """
  And the total tests line should equal "48 examples, 0 failures"
  And the error output should be empty
