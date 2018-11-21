module RSpec
  module TestSpec
    module ExampleGroup
      # In Rspec, example group bodies are delimited by 'describe' and
      # 'context' methods. These encapsulate examples, which are delimited
      # by 'it' methods. Example groups are evaluated in the context of an
      # ExampleGroup instance. Individual examples are evaluated in the
      # context of an instance of the ExampleGroup to which they belong.
      def include_steps(*args)
        name = args.shift

        shared_block = ::RSpec.world.shared_example_steps[name]
        shared_block || raise(ArgumentError,
          "Could not find shared steps #{name.inspect}")

        instance_exec(*args, &shared_block)
      end

      # rubocop:disable Naming/MethodName
      def Given(message, options = {}, &block)
        action :given, message, options, &block
      end

      def When(message, options = {}, &block)
        action :when, message, options, &block
      end

      def Then(message, options = {}, &block)
        action :then, message, options, &block
      end

      def And(message, options = {}, &block)
        action :and, message, options, &block
      end

      def But(message, options = {}, &block)
        action :but, message, options, &block
      end
      # rubocop:enable Naming/MethodName

      def rule(message, options = {}, &block)
        action :rule, message, options, &block
      end

      def fact(message, options = {}, &block)
        action :fact, message, options, &block
      end

      def test(message, options = {}, &block)
        action :test, message, options, &block
      end

      def step(message, options = {}, &block)
        action :step, message, options, &block
      end

      def it(message, options = {}, &block)
        action :it, message, options, &block
      end

      def specify(message, options = {}, &block)
        action :specify, message, options, &block
      end

      def example(message, options = {}, &block)
        action :example, message, options, &block
      end

      private

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def action(type, message, options = {}, &_block)
        ::RSpec.world.reporter.example_step_started(
          self, type, message, options
        )
        options = { pending: true } if options == :pending

        if block_given? && !options[:pending]
          begin
            yield
          rescue StandardError => e
            ::RSpec.world.reporter.example_step_failed(
              self, type, message, options
            )
            raise e
          end
          ::RSpec.world.reporter.example_step_passed(
            self, type, message, options
          )
        else
          ::RSpec.world.reporter.example_step_pending(
            self, type, message, options
          )
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
