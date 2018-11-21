Ability "Handle Pending Status" do
  Scenario "pending steps" do
    Given "context"
    When  "action"
    Then  "observable"

    Given "step without block and tag", pending: true
    Given "step without block and message", pending: "wip"
  end
end
