shared_steps "pushing to collection" do
  Given "an empty collection" do
    collection.clear
  end

  When "a single item is pushed to the collection" do
    collection.push "testing"
  end

  Then "the collection should have that single item" do
    expect(collection.items).to eq(["testing"])
  end
end

shared_steps "pulling from collection" do
  When "the last data is pulled from the collection" do
    collection.pull
  end

  Then "the collection should be empty" do
    expect(collection.items).to eq([])
  end
end

shared_steps "pushing specific item to collection" do |value|
  When "pushing an item to the collection" do
    collection.push value
  end
end

Story "duplicating shared steps is not allowed" do
  it "errors will be raised" do
    expect {
      shared_steps "duplicate" do
      end

      shared_steps "duplicate" do
      end
    }.to raise_error ArgumentError
  end
end

#RSpec.describe do
  Feature "demonstration of shared steps" do
    let :collection do
      Class.new do
        def initialize
          @values = []
        end

        def items
          @values
        end

        def clear
          @values = []
        end

        def push(value)
          @values << value
        end

        def pull
          @values.shift
        end
      end.new
    end

    Scenario "handles collections" do
      include_steps "pushing to collection"
      include_steps "pulling from collection"
    end

    Scenario "counts items in a collection" do
      include_steps "pushing to collection"

      Then "the collection should have one item" do
        expect(collection.items.size).to eq(1)
      end

      include_steps "pulling from collection"
    end

    Scenario "pushes new item to a collection" do
      include_steps "pushing specific item to collection", "tester"

      expect(collection.items).to eq(["tester"])
      expect(collection.items.size).to eq(1)

      include_steps "pulling from collection"
    end
  end
#end
