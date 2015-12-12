require 'test_helper'

class CommentOperationTest < MiniTest::Spec
  let (:thing) { Thing::Create.(thing: {name: "Ruby"}).model }

  describe "Create" do
    it "persists valid" do
      res, op = Comment::Create.run(
        comment: {
          body:   "Fantastic!",
          weight: "1",
          user:   { email: "jonny@trb.org" }
        },
        thing_id: thing.id
      )
      comment = op.model

      comment.persisted?.must_equal true
      comment.body.must_equal "Fantastic!"
      comment.weight.must_equal 1

      comment.user.persisted?.must_equal true
      comment.user.email.must_equal "jonny@trb.org"

      op.thing.must_equal thing

      Tyrant::Authenticatable.new(comment.user).confirmable?.must_equal true
    end

    it "invalid" do
      res, operation = Comment::Create.run(
        comment: {
          body:   "Fantastic!",
          weight: "1"
        }
      )

      res.must_equal false
      operation.errors.messages.must_equal(:thing=>["can't be blank"], :"user.email"=>["can't be blank", "is invalid"] )
    end

    it "invalid email, no weight" do
      res, operation = Comment::Create.run(
        comment: {
          user:   { email: "1337@" }
        }
      )

      res.must_equal false
      operation.errors.messages[:"user.email"].must_equal ["is invalid"]
      operation.errors.messages[:"weight"].must_equal ["is not included in the list"]
    end

    it "invalid body" do
      res, operation = Comment::Create.run(
        comment: {
          body:   "Fantastic, but a little bit to long this piece of shared information is! Didn't we say that it has to be less than 16 characters? Well, maybe you should listen to what I say."
        }
      )

      res.must_equal false
      operation.errors.messages[:"body"].must_equal ["is too long (maximum is 160 characters)"]
    end
  end


  # # create only works once with unconfirmed user.
  it do
    params = {
      thing_id: thing.id,
      comment:  {"body"=>"Fantastic!", "weight"=>"1", "user"=>{"email"=>"joe@trb.org"}}
    }

    op = Comment::Create.(params)

    # second call is invalid!
    res, op = Comment::Create.run(params)

    res.must_equal false
    op.contract.errors.to_s.must_equal "{:users=>[\"User is unconfirmed and already assign to another thing or reached comment limit.\"]}"
  end

  # existing comment email will associate user.
  it do
    user = Session::SignUp::Admin.(user: {"email"=>"joe@trb.org"}).model
    op = Comment::Create.(
      thing_id: thing.id,
      comment:  {"body"=>"Fantastic!", "weight"=>"1", "user"=>{"email"=>"joe@trb.org"}}
    )
    op.model.user.id.must_equal user.id
  end


  class CommentSignedInTest < MiniTest::Spec
    let (:thing) { Thing::Create[thing: {name: "Ruby"}].model }
    let (:user) { User.create(email: "liza@trb.org") } # TODO: operation.

    # valid
    it do
      res, op = Comment::Create::SignedIn.run(
        comment: {
          body:   "Fantastic!",
          weight: "1"
        },
        thing_id:     thing.id,
        current_user: user
      )
      res.must_equal true

      comment = op.model

      comment.persisted?.must_equal true
      comment.body.must_equal "Fantastic!"
      comment.weight.must_equal 1

      comment.user.must_equal user
      comment.thing.must_equal thing
      user.auth_meta_data.must_equal nil # TODO: this is how i test that callback hasn't been run, currently.
    end
  end
end