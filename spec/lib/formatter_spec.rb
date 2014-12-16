require 'spec_helper'

describe Vigia::Formatter do

  let(:output)       { double }
  let(:notification) { double }

  subject do
    described_class.new(output)
  end

  describe '#example_pending' do
    after do
      subject.example_pending(notification)
    end

    it 'calls output_example_result with the right parameters' do
      expect(subject).to receive(:output_example_result).with(notification, :pending)
    end
  end

  describe '#example_passed' do
    after do
      subject.example_passed(notification)
    end

    it 'calls output_example_result with the right parameters' do
      expect(subject).to receive(:output_example_result).with(notification, :success)
    end
  end

  describe '#example_failed' do
    after do
      subject.example_failed(notification)
    end

    it 'calls output_example_result with the right parameters' do
      expect(subject).to receive(:output_example_result).with(notification, :failed)
    end
  end
end
