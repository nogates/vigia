Vigia::Sail::Example.register(
  :code_match,
  description: 'has the expected HTTP code',
  expectation: -> { expect(result.code).to be(expectations.code) }
)

Vigia::Sail::Example.register(
  :include_headers,
  description: 'includes the expected headers',
  expectation: -> { expect(result[:headers]).to include(expectations[:headers]) }
)
