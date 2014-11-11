require 'spec_helper'

describe Vigia::Sail::RSpecObject do

  let(:options)       { double(:'[]' => nil) }
  let(:rspec_context) { double(described_class: testing_described_class) }
  let(:testing_described_class) { double }

  subject do
    described_class.new :name, options, rspec_context
  end

  describe '#contextual_object' do
    let(:option_name) { nil }
    let(:object)      { nil }
    let(:context)     { nil }

    after do
      subject.contextual_object(option_name: option_name, object: object, context: context)
    end

    context 'when context is passed' do
      let(:context) { rspec_context }

      context 'when is a proc' do
        let(:object)  { -> { 'a proc' } }

        it 'executes the proc inside that context' do
          expect(rspec_context).to receive(:instance_exec)
        end
      end
      context 'when is a symbol' do
        let(:object) { :class }

        it 'calls the symbol as a method on the adapter' do
          expect(rspec_context).to receive(:adapter)
        end
      end
    end

    context 'when context is nil' do
      context 'when is a proc' do
        let(:object)  { -> { 'a proc' } }

        it 'executes the proc inside the rspec described_class' do
          expect(testing_described_class).to receive(:instance_exec)
        end
      end
      context 'when is a symbol' do
        let(:object) { :class }

        it 'calls the symbol as a method on the adapter' do
          expect(testing_described_class).to receive(:adapter)
        end
      end
    end

#       context 'when object is nil' do
#         let(:object) { nil }
#
#         it 'uses the options' do
#           expect(options
#

  end

end

#
# module Vigia
#   module Sail
#     class RSpecObject
#       class << self
#         attr_accessor :collection
#
#         def setup_and_run(name, rspec)
#           name, options  = collection.select{ |k,v| k == name }.first
#           instance = new(name, options, rspec)
#           instance.run
#         end
#       end
#
#       attr_reader :name, :options, :rspec
#
#       def initialize(name, options, rspec)
#         @name    = name
#         @options = options
#         @rspec   = rspec
#
#       end
#
#       def execute_hook(filter_name)
#         hooks_for_object(filter_name).each do |hook|
#           rspec.instance_exec(&hook)
#         end
#       end
#
#       def hooks_for_object(filter_name)
#         config_hooks(filter_name) + object_hooks(filter_name)
#       end
#
#       def contextual_object(option_name: nil, object: nil, context: nil)
#         context ||= rspec.described_class
#         object  ||= options[option_name]
#         case object
#         when Symbol
#           context.adapter.send(object)
#         when Proc
#           context.instance_exec(&object)
#         else
#           object
#         end
#       end
#
#       private
#
#       def object_hooks(filter_name)
#         option_name = "#{ filter_name }_#{ self.class.name.split('::').last.downcase }".to_sym
#         [ *options[option_name] ].compact
#
#       end
#
#       def config_hooks(filter_name)
#         Vigia.config.hooks.each_with_object([]) do |hook, collection|
#           next unless self.is_a?(hook[:rspec_class]) and filter_name == hook[:filter]
#           collection << hook[:block]
#         end
#       end
#     end
#   end
# end
