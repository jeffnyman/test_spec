module TestSpec
  module Spec
    def self.included(base)
      base.instance_eval do
        alias :Feature    :context
        alias :Ability    :context
        alias :Story      :context
        alias :Component  :context
        alias :Workflow   :context

        alias :Background :before
        alias :Setup      :before
        alias :Teardown   :after
      end
    end
  end
end

# rubocop:disable Naming/MethodName
def self.Feature(*args, &block)
  RSpec.describe(*args, &block)
end

def self.Ability(*args, &block)
  RSpec.describe(*args, &block)
end

def self.Story(*args, &block)
  RSpec.describe(*args, &block)
end

def self.Component(*args, &block)
  RSpec.describe(*args, &block)
end

def self.Workflow(*args, &block)
  RSpec.describe(*args, &block)
end
# rubocop:enable Naming/MethodName

RSpec.configuration.include TestSpec::Spec
