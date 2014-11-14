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
        described_objects.each_with_index do |object, index|
          group_instance = create_group_instance(object, index)
          rspec.describe group_instance do
            let(group_instance.group.name) { group_instance.described_object }

            group_instance.run(self)
          end
        end
      end

      def children
        [ *options[:children] ] || []
      end

      def contexts
        [ *options[:contexts] ] || []
      end

      def described_objects
        contextual_object(option_name: :describes) || []
      end

      def create_group_instance(object, index)
        instance_name = "#{ name }#{ index }"
        Vigia::Sail::GroupInstance.new(instance_name, options, rspec).tap do |instance|
          instance.define_singleton_method("#{ name }", -> { object })
          instance.parent_object    = rspec.described_class.described_object unless options[:primary]
          instance.described_object = object
          instance.description      = (options[:description] || object.to_s)
          instance.group            = self
        end
      end
    end
  end
end
