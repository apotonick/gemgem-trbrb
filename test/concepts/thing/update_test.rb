require 'test_helper'

class ThingUpdateTest < MiniTest::Spec
  let (:current_user) { User::Create.(user: {email: "fred@trb.org"}).model }
  let (:admin)        { User::Create.(user: {email: "admin@trb.org"}).model }
  let (:author)       { User::Create.(user: {email: "solnic@trb.org"}).model }

  describe "anonymous" do
    let (:thing) { Thing::Create.(thing: {name: "Rails", description: "Kickass web dev", "users"=>[{"email"=>"solnic@trb.org"}]}).model }

    it do
      assert_raises Trailblazer::NotAuthorizedError do
        Thing::Update.(
          id: thing.id,
          thing: {name: "Rails", description: "Kickass web dev"})
      end
    end
  end

  # TODO: test "remove"!
  describe "signed-in" do
    let (:thing) { Thing::Create.(thing: {name: "Rails", description: "Kickass web dev", users: ["email"=>author.email]}).model }

    it "denies when no authors" do
      thing = Thing::Create.(thing: {name: "Rails", description: "Kickass web dev"}).model
      assert_raises Trailblazer::NotAuthorizedError do
        Thing::Update.(
          id:           thing.id,
          thing:        {description: "Well..."},
          current_user: current_user)
      end
    end

    it "denies when other author" do
      thing.id

      assert_raises Trailblazer::NotAuthorizedError do
        Thing::Update.(
          id:           thing.id,
          thing:        {description: "Well..."},
          current_user: current_user)
      end
    end

    it "persists valid, ignores name, ignores is_author" do
      Thing::Update.(
        id:           thing.id,
        thing:        {name: "Lotus", description: "MVC, well..", is_author: "1"},
        current_user: author).model

      thing.reload
      thing.name.must_equal "Rails"
      thing.description.must_equal "MVC, well.."
      thing.users.must_equal [author]
    end





    describe "adding and removing users" do
      before { author }
      it "valid, new and existing email" do
        solnic = thing.users[0]
        model  = Thing::Update.(
          id: thing.id,
          thing: {"users" => [{"id"=>solnic.id, "email"=>"solnicXXXX@trb.org"}, {"email"=>"nick@trb.org"}]},
          current_user: author).model

        model.users.size.must_equal 2
        model.users[0].attributes.slice("id", "email").must_equal("id"=>solnic.id, "email"=>"solnic@trb.org") # existing user, nothing changed.
        model.users[1].email.must_equal "nick@trb.org" # new user created.
        model.users[1].persisted?.must_equal true
      end

      # hack: try to change emails.
      it "doesn't allow changing existing email" do
        op = Thing::Create.(thing: {name: "Rails  ", users: [{"email"=>"solnic@trb.org"}]})

        op = Thing::Update.(
          id: op.model.id,
          thing: {users: [{"email"=>"wrong@nerd.com"}]},
          current_user: author)
        op.model.users[0].email.must_equal "solnic@trb.org"
      end

      # remove
      it "allows removing" do
        op  = Thing::Create.(thing: {name: "Rails", users: [{"email"=>"solnic@trb.org"}]})
        joe = op.model.users[0]

        res, op = Thing::Update::SignedIn.run(
          id: op.model.id,
          thing: {name: "Rails", users: [{"id"=>joe.id.to_s, "remove"=>"1"}]},
          current_user: author)

        res.must_equal true
        op.model.users.must_equal []
        joe.persisted?.must_equal true
      end
    end
  end

  describe "admin" do
    let (:thing) { Thing::Create.(thing: {name: "Rails", description: "Kickass web dev", users: ["email"=>author.email]}).model }

    it "persists when not author" do
      thing = Thing::Create.(thing: {name: "Rails", description: "Kickass web dev"}).model
      Thing::Update.(
        id:           thing.id,
        thing:        {name: "Lotus", description: "Well..."},
        current_user: admin)

      thing.reload
      thing.name.must_equal "Lotus"
      thing.description.must_equal "Well..."
    end
  end
end


    # FIXME: shit, this test passes, even though i want it to fail. :)
    # it "allows removing signed_in user" do
    #   op  = Thing::Create.(
    #     current_user: current_user,
    #     thing:        {name: "Rails  ", users: [{"email"=>"joe@trb.org"}], "is_author"=>1}
    #   )
    #   joe = op.model.users[0]
    #   op.model.users.size.must_equal 2

    #   res, op = Thing::Update.run(id: op.model.id, thing: {name: "Rails",
    #     users: [{"id"=>joe.id.to_s, "remove"=>"1"},
    #             {"id"=>current_user.id.to_s, "remove"=>"1"}]
    #   })

    #   res.must_equal true
    #   op.model.users.must_equal []
    #   joe.persisted?.must_equal true
    #   current_user.persisted?.must_equal true
    # end
  # end
# end