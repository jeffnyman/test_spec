require "rspec/core"
require "rspec/core/world"
require "rspec/core/reporter"
require "rspec/core/formatters"
require "rspec/core/example_group"
require "rspec/core/formatters/console_codes"
require "rspec/core/formatters/documentation_formatter"

require "test_spec/spec"
require "test_spec/version"
require "test_spec/rspec/world"
require "test_spec/rspec/reporter"
require "test_spec/rspec/formatter"
require "test_spec/rspec/notification"
require "test_spec/rspec/example_group"

RSpec::Core::ExampleGroup.send :include, RSpec::TestSpec::ExampleGroup
RSpec::Core::Reporter.send :include, RSpec::TestSpec::Reporter
RSpec::Core::World.send :include, RSpec::TestSpec::World

RSpec::Core::ExampleGroup.define_example_method :Scenario, with_steps: true
RSpec::Core::ExampleGroup.define_example_method :Condition, with_steps: true
RSpec::Core::ExampleGroup.define_example_method :Behavior, with_steps: true

RSpec::Core::ExampleGroup.define_example_method :Step, with_steps: true
RSpec::Core::ExampleGroup.define_example_method :Test, with_steps: true
RSpec::Core::ExampleGroup.define_example_method :Rule, with_steps: true
RSpec::Core::ExampleGroup.define_example_method :Fact, with_steps: true

RSpec::Core::ExampleGroup.define_example_method :steps, with_steps: true
RSpec::Core::ExampleGroup.define_example_method :rules, with_steps: true
RSpec::Core::ExampleGroup.define_example_method :tests, with_steps: true
RSpec::Core::ExampleGroup.define_example_method :facts, with_steps: true

require "test_spec/rspec/shared_steps"
# rubocop:disable Style/MixinUsage
include RSpec::TestSpec::SharedSteps
# rubocop:enable Style/MixinUsage
