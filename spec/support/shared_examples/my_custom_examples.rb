# This share example runs in all requests
shared_examples 'my custom examples' do |_specapib_example, response|
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

# This share example runs only in Scenarios Resource requests
shared_examples 'scenarios resource examples' do |_specapib_example, response|
  before do
    @json_result = JSON.parse(result[:body])
  end
  it 'contains scenarios class' do
    expect(@json_result['class']).to include('scenarios')
  end
end

# This share example runs only in get /scenarios get action
shared_examples 'scenarios get index action examples' do |_specapib_example, response|
  before do
    @json_result = JSON.parse(result[:body])
  end
  it 'contains actions key' do
    expect(@json_result['actions']).not_to be_nil
  end
end
