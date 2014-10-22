shared_examples 'skip example' do |runner_example|

  let(:runner_example) { runner_example }

  runner_example.apib_example.responses.each do |response|
    context description_for(response) do
      context "when requesting #{ runner_example.url }" do

        it '# disabled with @skip' do
          expect(runner_example.skip?).to be_truthy
        end
      end
    end
  end
end
