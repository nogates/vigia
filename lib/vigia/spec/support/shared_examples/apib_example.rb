shared_examples 'apib example' do |runner_example|

  let(:runner_example) { runner_example }

  runner_example.apib_example.responses.each do |response|
    context description_for(response) do
      context "when requesting #{ runner_example.compile_url }" do

        let(:response)       { response }
        let!(:expectations)  { runner_example.expectations_for(response) }
        let!(:result)        { runner_example.perform_request(response) }

        it 'returns the expected HTTP code' do
          expect(result[:code]).to eql(expectations[:code]),
            -> { format_error(result, expectations) }
        end

        it 'returns the expected HTTP headers' do
          expect(result[:headers]).to include(expectations[:headers]),
            -> { format_error(result, expectations) }
        end

        if runner_example.custom_examples.any?
          context 'when running custom rspec examples' do
            runner_example.custom_examples.each do |example_name|
              include_examples example_name, runner_example, response
            end
          end
        end
      end
    end
  end
end
