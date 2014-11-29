require 'spec_helper'

require_relative '../../lib/vigia/spec/support/utils'

describe 'Utils methods' do
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
