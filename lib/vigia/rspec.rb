module Vigia
  class Rspec
    class << self
      def adapter
        @@adapter
      end

      def include_shared_folders
        require_custom_examples
        require "#{ __dir__ }/spec/support/utils"
        require "#{ __dir__ }/spec/support/shared_examples/skip_example"
        require "#{ __dir__ }/spec/support/shared_examples/apib_example"
      end

      private
      def require_custom_examples
        if Vigia.config.custom_examples_paths
          [ *Vigia.config.custom_examples_paths ].sort.each do |example_file|
            require example_file
          end
        end
      end
    end

    def run!
      with_rspec_options do
        RSpec::Core::Runner::run(
          [ Vigia.spec_folder ], Vigia.config.stderr, Vigia.config.stdout)
      end
    end

    def start_tests(rspec)
      with_rspec_options do
        set_global_memoizers(rspec)

        Vigia::Sail::Group.setup_and_run_primary(rspec)
      end
    end

    def set_global_memoizers(rspec)
      instance = adapter
      rspec.let(:client)  { Vigia.config.http_client_class.new(http_client_options) }
      rspec.let(:result)  { client.run }
      rspec.let(:result!) { client.run! }
      rspec.let(:adapter) { instance }
    end

    def adapter
      @@adapter ||= Vigia.config.adapter.instance
    end

    private

    def with_rspec_options
      RSpec.configure do |config|
        configure_vigia_rspec(config)
      end
      yield
    end

    def configure_vigia_rspec(rspec_config)
      return unless Vigia.config.rspec_config_block.respond_to?(:call)
      Vigia.config.rspec_config_block.call(rspec_config)
    end
  end
end
