require 'test_helper'

class ThingCrudTest < MiniTest::Spec
  describe "Create" do
    it "persists valid" do
      thing = Thing::Create[thing: {name: "Rails", description: "Kickass web dev"}].model

      thing.persisted?.must_equal true
      thing.name.must_equal "Rails"
      thing.description.must_equal "Kickass web dev"
    end

    it "invalid" do
      res, op = Thing::Create.run(thing: {name: ""})

      res.must_equal false
      op.contract.errors.to_s.must_equal "{:name=>[\"can't be blank\"]}"
      op.model.persisted?.must_equal false
    end
  end
end