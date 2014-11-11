module Vigia
  module Sail
    class Group < Vigia::Sail::RSpecObject
      class << self
        def setup_and_run_primary(rspec)
          name, options  = collection.select{ |k,v| v[:primary] == true }.first
          instance = new(name, options, rspec)
          instance.run
        end
      end

      def run
        setup_objects
        describe_objects
      end

      def children
        [ *options[:children] ] || []
      end

      def contexts
        [ *options[:contexts] ] || []
      end

      def setup_objects
        @describes = set_describe_objects
      end

      def describe_objects
        @describes.each do |object|
          rspec.describe object do
            let(object.ocean.name) { object.described_object }

            object.ocean.children.each do |group_name|
              Vigia::Sail::Group.setup_and_run(group_name, self)
            end

            object.ocean.contexts.each do |context_name|
              Vigia::Sail::Context.setup_and_run(context_name, self)
            end
          end
        end
      end

      def set_describe_objects
        described_objects = contextual_object(option_name: :describes)
        described_objects.each_with_object([]) do |object, classes|
          classes << create_described_object(object)
        end
      end

      def create_described_object(object)
        Vigia::Sail::DescribedClass.new.tap do |instance|
          instance.send("#{ name }=", object)
          instance.parent_object    = rspec.described_class.described_object unless options[:primary]
          instance.described_object = object
          instance.description      = (options[:description] || object.to_s)
          instance.ocean            = self
        end
      end
    end
  end
end
