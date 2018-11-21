module RSpec
  module TestSpec
    module Reporter
      # An RSpec reporter sends notifications to listeners. The listeners
      # are usually formatters for a specific test run.
      def example_step_started(example, type, message, options)
        notify :example_step_started,
          Notification.new(example, type, message, options)
      end

      def example_step_passed(example, type, message, options)
        notify :example_step_passed,
          Notification.new(example, type, message, options)
      end

      def example_step_failed(example, type, message, options)
        notify :example_step_failed,
          Notification.new(example, type, message, options)
      end

      def example_step_pending(example, type, message, options)
        notify :example_step_pending,
          Notification.new(example, type, message, options)
      end

      def registered_formatters
        @listeners.values.map(&:to_a).flatten.uniq
      end

      def find_registered_formatter(cls)
        registered_formatters.detect { |formatter| formatter.class == cls }
      end
    end
  end
end
