module RSpec
  module TestSpec
    module SharedSteps
      def shared_steps(name, &block)
        ensure_shared_example_steps_name_not_taken(name)
        ::RSpec.world.shared_example_steps[name] = block
      end

      private

      def ensure_shared_example_steps_name_not_taken(name)
        return unless ::RSpec.world.shared_example_steps.key?(name)

        raise(ArgumentError, "Shared step '#{name}' already exists")
      end
    end
  end
end
