require 'spec_helper'

require_relative '../../lib/specapib/spec/support/utils'

describe 'Utils methods' do
  describe '#description_for' do
    context 'when object is a RedSnow::ResourceGroup' do
      let(:object) do 
        example_apib.ast.resource_groups.first
      end
      it 'returns the proper description' do
        expect(description_for(object)).to eql('Resource Group: Scenarios')
      end
    end
    context 'when object is a RedSnow::Resource' do
      let(:object) do 
        example_apib.ast.resource_groups.first.resources.first
      end
      it 'returns the proper description' do
        expect(description_for(object)).to eql('Resource: Scenarios (/scenarios{?page,sort})')
      end
    end
    context 'when object is a RedSnow::Action' do
      let(:object) do 
        example_apib.ast.resource_groups.first.resources.first.actions.first
      end
      it 'returns the proper description' do
        expect(description_for(object)).to eql('Action: Retrieve all Scenarios (GET)')
      end
    end
    context 'when object is a RedSnow::Payload' do
      let(:object) do 
        example_apib.ast.resource_groups.first.resources.first.actions.first.examples.first.responses.first
      end
      it 'returns the proper description' do
        expect(description_for(object)).to eql('Response: 200')
      end
    end
  end
  describe '#format_error' do
    
    let(:result)      { instance_double(Hash, inspect: 'Inspecting Result') }
    let(:expectation) { instance_double(Hash, inspect: 'Inspecting Expectation') }
    
    context 'while formatting the error' do
      before do
        format_error(result, expectation)
      end
      it 'calls the inspect method on result' do
        expect(result).to have_received(:inspect)
      end
      it 'calls the inspect method on expectation' do
        expect(expectation).to have_received(:inspect)
      end
    end
    
    it 'returns the proper format' do
      expected_format = <<-EXPECTED

  Expected:

    Inspecting Expectation

  Got:

    Inspecting Result


      EXPECTED
      expect(format_error(result, expectation)).to eql(expected_format)
    end
  end
end
