module RSpec
  module TestSpec
    module World
      # RSpec's 'world' is an internal container that is used for
      # holding global non-configuration data.
      def shared_example_steps
        @shared_example_steps ||= {}
      end
    end
  end
end
