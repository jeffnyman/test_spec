Feature "feature" do
  Ability "ability" do
    Scenario "scenario" do
      Given "context" do
        @given = 'given'
      end

      When "action" do
        @when = 'when'
      end

      Then "result" do
        @then = "then"
      end

      expect(@given).to eq("given")
      expect(@when).to eq("when")
      expect(@then).to eq("then")
    end

    Condition "condition" do
      When "action" do
        @when = "when"
      end

      And "action" do
        @and = 'and'
      end

      But "but" do
        @but = "but"
      end

      expect(@when).to eq("when")
      expect(@and).to eq("and")
      expect(@but).to eq("but")
    end

    Fact "fact" do
      fact "fact" do
        @fact = "fact"
      end

      expect(@fact).to eq("fact")
    end

    Rule "rule" do
      rule "rule" do
        @rule = "rule"
      end

      expect(@rule).to eq("rule")
    end

    Step "step" do
      it "it" do
        @it = "it"
      end

      specify "specify" do
        @specify = "specify"
      end

      example "example" do
        @example = "example"
      end

      expect(@it).to eq("it")
      expect(@specify).to eq("specify")
      expect(@example).to eq("example")
    end

    Condition "failing steps" do
      expect {
        specify "expectation alerts failure" do
          expect(2 + 2).to eq 5
        end
      }.to raise_error RSpec::Expectations::ExpectationNotMetError
    end
  end
end
