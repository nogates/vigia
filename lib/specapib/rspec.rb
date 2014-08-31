module SpecApib
  class Rspec
    class << self
      def apib
        SpecApib.config.blueprint.apib
      end

      def include_shared_folders
        require_custom_examples
        require "#{ __dir__ }/spec/support/utils"
        require "#{ __dir__ }/spec/support/shared_examples/apib_example"
      end

      private
      def require_custom_examples
        if SpecApib.config.custom_examples_paths
          [ *SpecApib.config.custom_examples_paths ].sort.each do |example_file|
            require example_file
          end
        end
      end
    end

    # Run `SpecApib.spec_folder` spec file
    def run!
      with_options do
        RSpec::Core::Runner::run(
          [ SpecApib.spec_folder ], $stderr, $stdout)
      end
    end

    private

    # ToDo: Do we need rspec config?

    def with_options &block
      RSpec.configure do |config|
        config.before(:each) do |example|
        end
        config.before(:suite) do
        end
      end
      yield
    end
  end
end
