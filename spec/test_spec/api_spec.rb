Component "component block" do
  Background "background" do
    Given "background" do
    end
  end

  Setup "setup" do
    Given "setup" do
    end
  end

  Teardown "teardown" do
    step "teardown" do
    end
  end

  steps "steps block" do
    step "step block" do
      @result = "result"
      expect(@result).to eq("result")
    end
  end

  Step "step block" do
    step "step block" do
      @result = "result"
      expect(@result).to eq("result")
    end
  end

  tests "tests block" do
    test "test block" do
      @result = "result"
      expect(@result).to eq("result")
    end
  end

  Test "test block" do
    test "test block" do
      @result = "result"
      expect(@result).to eq("result")
    end
  end

  rules "rules block" do
    rule "rule block" do
      @result = "result"
      expect(@result).to eq("result")
    end
  end

  Rule "rule block" do
    rule "rule block" do
      @result = "result"
      expect(@result).to eq("result")
    end
  end
end
