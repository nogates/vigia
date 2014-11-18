module Vigia
  module Sail
    class GroupInstance < Vigia::Sail::RSpecObject

      attr_accessor :parent_object, :described_object, :group, :description

      def run(rspec_context)
        with_hooks(rspec_context) do
          group.children.each do |group_name|
            Vigia::Sail::Group.setup_and_run(group_name, rspec_context)
          end

          group.contexts.each do |context_name|
            Vigia::Sail::Context.setup_and_run(context_name, rspec_context)
          end
        end
      end

      def to_s
        description.respond_to?(:call) ? instance_exec(&description) : description
      end
    end
  end
end
