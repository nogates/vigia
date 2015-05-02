module Vigia
  module Sail
    module Examples
      module Default
        module_function

        def load!
          Vigia::Sail::Example.register(
            :code_match,
            description: 'has the expected HTTP code',
            expectation: -> {
              if expectations.code.is_a?(Range)
                expect(expectations.code.member?(result.code)).to be true
              else
                expect(result.code).to be(expectations.code)
              end
            }
          )

          Vigia::Sail::Example.register(
            :include_headers,
            description: 'includes the expected headers',
            expectation: -> { expect(result.headers).to include(expectations.headers) }
          )
        end
      end
    end
  end
end
