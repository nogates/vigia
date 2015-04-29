require 'spec_helper'

describe Vigia::Adapters::Raml do

  let(:config) do
    instance_double(
      Vigia::Config,
      source_file: 'my_raml_file'
    )
  end

  before do
    Vigia.reset!
    allow(Vigia).to receive(:config).and_return(config)
  end

  describe 'adapter structure' do
    context 'testing an instance' do
      # using cucumber my_blog.raml
      let(:instance) { described_class.instance }

      before do
        allow(config).to receive(:source_file)
          .and_return(File.join(__dir__, '../../../features/support/examples/my_blog/my_blog.raml'))
        instance
      end

      it 'loads up the sail groups' do
        expect(Vigia::Sail::Group.collection.keys)
          .to match_array [ :resource, :method, :response, :body ]
      end

      it 'loads up the sail contexts' do
        expect(Vigia::Sail::Context.collection.keys)
          .to match_array [ :default ]
      end
    end
  end
end
