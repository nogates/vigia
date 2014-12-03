require 'spec_helper'

describe Vigia::Adapters::Blueprint do

  include_examples "redsnow doubles"

  let(:config) do
    instance_double(
      Vigia::Config,
      source_file: 'my_blueprint_file'
    )
  end

  before do
    allow(Vigia).to receive(:config).and_return(config)
  end

  describe '::setup_adapter' do

    context 'when loading the file' do
      after do
        load File.join(__dir__, '../../../lib/vigia/adapters/blueprint.rb')
      end

      it 'runs the setup adapter at start' do
        expect(described_class).to receive(:setup_adapter)
      end
    end

    context 'testing adapter template' do
      let(:template) { described_class.template }
      let(:structure) do
        instance_double(
          Vigia::Adapter::Structure,
          after_initialize: nil,
          group: nil,
          context: nil
        )
      end

      after do
        structure.instance_exec(&template)
      end

      it 'sets the resource_group group' do
        expect(structure).to receive(:group)
          .with(:resource_group, hash_including(primary: true, children: [ :resource ]))
      end

      it 'sets the resource group' do
        expect(structure).to receive(:group)
          .with(:resource, hash_including(children: [ :action ]))
      end

      it 'sets the action group' do
        expect(structure).to receive(:group)
          .with(:action, hash_including(children: [ :transactional_example ]))
      end

      it 'sets the transactional example group' do
        expect(structure).to receive(:group)
          .with(:transactional_example, hash_including(children: [ :response ]))
      end

      it 'sets the response group' do
        expect(structure).to receive(:group)
          .with(:response, hash_including(contexts: [ :default ]))
      end

      it 'sets the default context' do
        expect(structure).to receive(:context).with(:default, kind_of(Hash))
      end

      it 'calls after_initialize' do
        expect(structure).to receive(:after_initialize)
      end
    end

    context 'testing an instance' do
      # using cucumber my_blog.apib
      let(:instance) { described_class.instance }

      before do
        allow(config).to receive(:source_file)
          .and_return(File.join(__dir__, '../../../features/support/examples/my_blog/my_blog.apib'))
        described_class.instance
      end

      it 'loads up the sail groups' do
        expect(Vigia::Sail::Group.collection.keys)
          .to match_array [ :resource_group, :resource, :action, :transactional_example, :response ]
      end

      it 'loads up the sail contexts' do
         expect(Vigia::Sail::Context.collection.keys)
          .to match_array [ :default ]
      end
    end
  end

  describe '#payload_for' do
    context 'when the payload exists' do
      let(:payload_body) { 'The body' }
      it 'returns the payload' do
        expect(subject.payload_for(apib_example, response))
          .to eql('The body')
      end
    end

    context 'when the payload does not exist' do
      let(:other_response) do
        instance_double(
          RedSnow::Payload,
          name:    'A different response'
        )
      end
      it 'raises an error' do
        expect { subject.payload_for(apib_example, other_response) }
          .to raise_error('Unable to load payload for response A different response')
      end
    end
  end
end
