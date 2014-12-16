RSpec::Support.require_rspec_core 'formatters/base_text_formatter'

module Vigia
  class Formatter < RSpec::Core::Formatters::BaseTextFormatter

    include RSpec::Core::Formatters::ConsoleCodes

    RSpec::Core::Formatters.register self, :start, :example_group_started, :example_group_finished,
                                           :example_pending, :example_passed, :example_failed

    def initialize(output)
      super
      @example_collection = {}
      @group_level        = 0
      @verbose            = false
    end

    def start(start_notification)
      output.puts 'Starting Vigia::RSpec'
    end

    def example_group_started(example_group_notification)
      @group_level += 1
    end

    def example_group_finished(example_group_notification)
      @group_level -= 1
    end

    def example_pending(example_notification)
      output_example_result(example_notification, :pending)
    end

    def example_passed(example_notification)
      output_example_result(example_notification, :success)
    end

    def example_failed(failed_example_notification)
      output_example_result(failed_example_notification, :failed)
     end

    def dump_failures(examples_notification)
      @examples_notification = examples_notification
      print_context_failures
    end

    private

    def print_context_failures
      examples_by_context.each do |context, examples|
        print_context_failure(context, examples)
      end
    end

    def examples_by_context
      @examples_notification.failed_examples.each_with_object({}) do |example, hash|
        context         = example.metadata[:example_group]
        hash[context] ||= []
        hash[context] << example
        hash
      end
    end

    def print_context_failure(context, examples)
      output.puts(''.tap do |string|
        string << context_failure_title(context)
        string << context_failure_examples(context, examples)
        string << context_parents(context)
      end)
    end

    def context_parents(context)
      "\nGroups:\n#{ context_parent(context[:parent_example_group], '') }"
    end

    def context_parent(context, string)
      string << "  - #{ context[:described_class].group.name } #{ context[:described_class].to_s }"
      if Vigia::Rspec.adapter.respond_to?(:inspector)
        info = Vigia::Rspec.adapter.inspector(context[:described_class].described_object)
        string << wrap(" # #{ Vigia.config.source_file }:#{ info[:line] }", :cyan)
      end
      string << "\n"
      unless context[:parent_example_group][:described_class] == Vigia::Rspec
        string = context_parent(context[:parent_example_group], string)
      end
      string
    end

    def context_failure_title(context)
      wrap("\nContext `#{ wrap(context[:description], :cyan) }` FAILED:", :bold)
    end

    def context_failure_examples(context, examples)
      context_examples = @examples_notification.examples.select do |e|
        e.metadata[:example_group] == context and e.execution_result.status == :failed
      end

      context_examples.each_with_object("\n") do |example, text|
        text <<  " - Example: #{ example.metadata[:description] }\n"
        text <<  "#{ wrap(example.exception.to_s, :failure) }"
      end
    end

    def output_example_result(notification, category)
      if @verbose
      else
        output.print(wrap('.', category))
      end
    end
  end
end
