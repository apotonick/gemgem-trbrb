require 'test_helper'

class ThingOperationTest < MiniTest::Spec
  describe "Create" do
    it "persists valid" do
      thing = Thing::Create.(thing: {name: "Rails", description: "Kickass web dev"}).model

      thing.persisted?.must_equal true
      thing.name.must_equal "Rails"
      thing.description.must_equal "Kickass web dev"
    end

    it "invalid" do
      res, op = Thing::Create.run(thing: {name: ""})

      res.must_equal false
      op.errors.to_s.must_equal "{:name=>[\"can't be blank\"]}"
      op.model.persisted?.must_equal false
    end

    it "invalid description" do
      res, op = Thing::Create.run(thing: {name: "Rails", description: "hi"})

      res.must_equal false
      op.errors.to_s.must_equal "{:description=>[\"is too short (minimum is 4 characters)\"]}"
    end
  end

  describe "Update" do
    let (:thing) { Thing::Create.(thing: {name: "Rails", description: "Kickass web dev"}).model }

    it "persists valid, ignores name" do
      Thing::Update.()
        id:     thing.id,
        thing: {name: "Lotus", description: "MVC, well.."}).model

      thing.reload
      thing.name.must_equal "Rails"
      thing.description.must_equal "MVC, well.."
    end
  end
end