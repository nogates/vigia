shared_examples 'my custom examples' do |_runner_example, response|
  if (200..201).include?(response.name.to_i)
    it 'is a valid json response' do
      expect { JSON.parse(result[:body]) }.not_to raise_error
    end
    it 'has same json response' do
      expect(result[:body]).to eql(expectations[:body])
    end
  elsif response.name.to_i == 204
    it 'body is nil' do
      expect(result[:body]).to eql('')
    end
  end
end
