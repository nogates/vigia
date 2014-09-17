shared_examples 'skip example' do |runner_example|

  let(:runner_example) { runner_example }

  runner_example.apib_example.responses.each do |response|
    context description_for(response) do
      context "when requesting #{ runner_example.compile_url }" do

        xit '# disabled with @skip' do
          # Do nothing
        end
      end
    end
  end
end
