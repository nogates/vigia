module Vigia
  module Hooks

    def execute_hook(filter_name, rspec_context)
      hooks_for_object(filter_name).each do |hook|
        if self.is_a?(Vigia::Sail::Context)
          instance = self
          rspec_context.define_singleton_method(:vigia_context, -> { instance })
        end

        rspec_context.instance_exec(&hook)
      end
    end

    def hooks_for_object(filter_name)
      config_hooks(filter_name) + object_hooks(filter_name)
    end

    def with_hooks(rspec_context)
      instance = self

      rspec_context.before(:context) do
        instance.execute_hook(:before, self)
      end

      rspec_context.after(:context) do
        instance.execute_hook(:after, self)
      end

      instance.execute_hook(:extend, rspec_context)

      yield
    end

    private

    def object_hooks(filter_name)
      return [] unless respond_to?(:options)
      option_name = "#{ filter_name }_#{ self.class.name.split('::').last.downcase }".to_sym
      [ *options[option_name] ].compact

    end

    def config_hooks(filter_name)
      Vigia.config.hooks.each_with_object([]) do |hook, collection|
        next unless self.is_a?(hook[:rspec_class]) and filter_name == hook[:filter]
        collection << hook[:block]
      end
    end
  end
end
