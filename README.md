# TestSpec

[![Gem Version](https://badge.fury.io/rb/test_spec.svg)](http://badge.fury.io/rb/test_spec)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jeffnyman/test_spec/blob/master/LICENSE.md)

> **The height of sophistication is simplicity.**<br>
> &nbsp;&nbsp;&nbsp;&nbsp;*Clare Boothe Brokaw*

---

TestSpec is a tool for leveraging RSpec to create an expressive DSL for test and data conditions.

TestSpec provides an internal DSL, similar to the [RSpec Story Runner](https://github.com/dchelimsky/rspec-stories). This was the predecessor of the [Cucumber](http://cukes.info/) external DSL provided by [Gherkin](http://cukes.info/gherkin.html).

Behavior Driven Development, or even just good Test Driven Development, practices put emphasis on communication. Tools like Cucumber focus on allowing communication via a test description language, structured by Gherkin keywords. However, while the ideas of Gherkin are nice, tools like Cucumber abstract away the nuts and bolts of your tests.

Abstraction can be a good thing but Cucumber gives you no choice in the matter. It hides code blocks behind a "call by regular expression" invocation mechanism instead of making those code blocks readily available in the test description.

TestSpec lets you write as much logic beside your specifications as you want by leveraging the RSpec ecosystem with the addition of a Gherkin-like syntax as well as additions to that syntax.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'test_spec'
```

To get the latest code:

```ruby
gem 'test_spec', git: 'https://github.com/jeffnyman/test_spec'
```

After doing one of the above, execute the following command:

```
$ bundle
```

You can also install TestSpec just as you would any other gem:

```
$ gem install test_spec
```

## Usage

To use TestSpec you simply have to require it within your `spec_helper` file:

```ruby
require 'test_spec'
```

Then you simply run your `rspec` command as normal against your test suite.

Because TestSpec uses a custom formatter, you should have an `.rspec` file with the following line in it:

```ruby
--format RSpec::TestSpec::Formatter
```

You can use RSpec constructs within TestSpec constructs although there are some things to be aware of. Here is an example:

```ruby
Feature 'Bank Accounts' do
  let(:valid_account_number) { '1234567890' }
  subject { Account.new(valid_account_number) }

  Scenario 'starting a new account' do
    test 'will have a starting balance of 0' do
      expect(subject.balance).to eq(0)
    end

    it 'will not allow an invalid account name' do
      expect { Account.new('thx1138') }.to raise_error(InvalidAccountNumberError)
    end
  end
end
```

You can see that within the Feature construct I have let and subject elements. Within the Scenario you can see I use a TestSpec method (Test) and an RSpec method (it).

## Documentation

TestSpec provides an internal DSL that allows you to use a Gherkin-like structural syntax within traditional RSpec test suites.

Note that while TestSpec does provide a Gherkin-like syntax, there is no parsing of an actual Gherkin feature file. This means there are no regular expression matchers that exist as part of step definitions.

Here's a typical (if simplified) example of a traditional RSpec test:

```ruby
describe 'The Nature of Truth' do
  context 'logic tests are applied' do
    it 'will realize that true is almost certainly not false' do
      expect(true).to_not be false
    end

    it 'will realize that true is pretty definitely true' do
      expect(true).to be true
    end
  end
end
```

The following examples will show how the above example can be utilized in the context of TestSpec's DSL.

As with Gherkin, you can provide a high-level **Feature** keyword to describe the overall set of tests. Here is one example of what you can do:

```ruby
Feature 'The Nature of Truth' do
  tests 'logic tests are applied' do
    test 'true is almost certainly not false' do
      expect(true).to_not be false
    end

    test 'true is pretty definitely true' do
      expect(true).to be true
    end
  end
end
```

Notice here the **tests** keyword. This is an alias for elements like RSpec's `context`. Further notice that a **Test** keyword can be used. Some people think of tests in terms of steps and TestSpec can accommodate that as follows:

```ruby
Feature 'The Nature of Truth' do
  steps 'logic tests are applied' do
    step 'true is almost certainly not false' do
      expect(true).to_not be false
    end

    step 'true is pretty definitely true' do
      expect(true).to be true
    end
  end
end
```

This is similar to the previous example, with the changes being the use of the **steps** and **Step** keywords.

Do note that unlike Gherkin feature files, you can have multiple **Feature** blocks within the test file. So you could have both of the above blocks co-existing and running together.

If you want to adhere even more strictly to Gherkin syntax, TestSpec does allow that:

```ruby
Feature 'The Nature of Truth' do
  Scenario 'simple logic tests are applied' do
    Then 'true is almost certainly not false' do
      expect(true).to_not be false
    end

    Then 'true is pretty definitely true' do
      expect(true).to be true
    end
  end
end
```

Here you can see the use of the **Scenario** keyword, which is encapsulating two Then test steps.

Gherkin structures allow you to use the word "Ability" as an alias for "Feature". However TestSpec takes the viewpoint that a feature could be speaking to a high-level viewpoint, within which there are multiple abilities. Thus you can use both descriptors simultaneously:

```ruby
Feature 'The Nature of Truth' do
  Ability 'logic tests can be applied' do
    Scenario 'true is not false' do
      Then 'true is almost certainly not false' do
        expect(true).to_not be false
      end
    end

    Scenario 'true is true' do
      Then 'true is pretty definitely true' do
        expect(true).to be true
      end
    end
  end
end
```

You can also see here that multiple **Scenario** blocks can be included within a Feature or Ability.

This should give a rough idea of how TestSpec provides an internal DSL.

## Design Rationale

TestSpec is a micro-framework.

A micro-framework provides a focused solution, which means it does one thing and one thing only, instead of trying to solve each and every problem. While doing that one thing it does well, the micro-framework should do it while being expressive and concise. Further, it should be able to serve as one component of your own custom modularized framework, allowing you to compose solutions.

### Frameworks are Effective and Efficient

I believe that test solution frameworks require effective functionality, an efficient user experience, and demonstrable business impact. This all has to be delivered, deployed, and supported quickly and cost-effectively. You want the equivalent of a lower total cost of ownership and a faster time-to-market for whatever you produce (such as test artifacts).

### Frameworks are Comfortable

Like a programming language, a framework needs to be something you're comfortable with -- something that reflects your personal style and mode of working. That's what TestSpec is for me.

TestSpec allows me to continue working with a Gherkin-like structure but putting my test specs closer to the code. Just as in RSpec, everything is in one place: the Ruby file. The benefit here is that you don't have to change the text in two places -- feature files and step definition files -- every time you change something. Further, there are no more matchers to sync up with natural language. TestSpec uses plain Ruby helper methods coupled with various patterns.

### Frameworks Provide

A framework provides a few key aspects.

A place for everything: Structure and convention drive a good framework. Everything should have a proper place within the system; this eliminates guesswork and increases productivity.

A culture and aesthetic to help inform programming decisions: Rather than seeing the structure imposed by a framework as constraining, see it as liberating. A good framework encodes its opinions, gently guiding you. Often, difficult decisions are made for you by virtue of convention. The culture of the framework helps you make fewer menial decisions and helps you focus on what matters most.

### Frameworks Have Qualities

I believe a test framework with good qualities will ...

* Encode opinions.
* Have an elegant, concise syntax.
* Have powerful metaprogramming features.
* Be well suited as a host language for creating DSLs.
* Allow for an open ecosystem.

### TestSpec (Conceptually) Compared

Even though their domains are different, consider TestSpec in light of Rails. Rails is more than a programming framework for creating web applications. It's also a framework for thinking about web applications.

Rails ships not as a blank slate equally tolerant of every kind of expression. On the contrary, Rails trades that flexibility for the convenience of "what most people need most of the time to do most things."

You could argue that Rails is a designer straightjacket. Yet this straightjacket sets you free from focusing on the things that just don't matter and focuses your attention on the stuff that does. To be able to accept that trade, you need to understand not just how to do something in Rails, but also why it's done like that. Only by understanding the why will you be able to consistently work with the framework instead of against it.

It doesn't mean that you'll always have to agree with a certain choice, but you will need to agree to the overachieving principle of conventions. You have to learn to relax and let go of your attachment to personal idiosyncrasies when the productivity rewards are right.

So it is with TestSpec.

A framework goal is to solve 80% of the problems that occur in your testing domain, assuming that the remaining 20% are problems that are unique to the application's domain. This implies that 80% of the code in an application is infrastructure. So here instead of focusing on the details of knitting an application together, you get to focus on the 20% that really matters.

The framework lets you start right away by encompassing a set of intelligent decisions about how your logic should work and alleviating the amount of low-level decision making you need to do up front. As a result, you can focus on the problems you're trying to solve and get the job done more quickly.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec:all` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To experiment with the code, run `bin/console` for an interactive prompt. If you want to make changes and see how they work as a gem installed on your local machine, run `bundle exec rake install`.

The default `rake` command will run all tests as well as a Rubocop analysis.

If you have rights to deploy a new version, make sure to update the version number in `version.rb`, and then run `bundle exec rake release`. This will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/jeffnyman/test_spec](https://github.com/jeffnyman/test_spec). The testing ecosystem of Ruby is very large and this project is intended to be a welcoming arena for collaboration on yet another test-supporting tool. As such, contributors are very much welcome but are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) which is provided as a [code of conduct](https://github.com/jeffnyman/test_spec/blob/master/CODE_OF_CONDUCT.md).

The TestSpec gems follows [semantic versioning](http://semver.org).

To contribute to TestSpec:

1. [Fork the project](http://gun.io/blog/how-to-github-fork-branch-and-pull-request/).
2. Create your feature branch. (`git checkout -b my-new-feature`)
3. Commit your changes. (`git commit -am 'new feature'`)
4. Push the branch. (`git push origin my-new-feature`)
5. Create a new [pull request](https://help.github.com/articles/using-pull-requests).

## Author

* [Jeff Nyman](http://testerstories.com)

## License

TestSpec is distributed under the [MIT](http://www.opensource.org/licenses/MIT) license.
See the [LICENSE](https://github.com/jeffnyman/test_spec/blob/master/LICENSE.md) file for details.

## Credits

TestSpec has been inspired by the following projects. Each provided me with ideas for what to do and, in some cases, for what not to do. All were invaluable as I better considered how to leverage RSpec's functionality.

* [maniok_bdd](https://github.com/21croissants/maniok_bdd)
* [rspec-gherkin](https://github.com/sheerun/rspec-gherkin)
* [rspec example steps](https://github.com/railsware/rspec-example_steps)
* [XSpec](https://github.com/xaviershay/xspec)
* [Mouse Melon](https://github.com/wojtha/mouse_melon)
