module Vigia
  module Sail
    class DescribedClass < OpenStruct
      def to_s
        description.respond_to?(:call) ? instance_exec(&description) : description
      end
    end
  end
end
