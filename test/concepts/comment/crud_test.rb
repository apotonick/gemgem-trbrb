require 'test_helper'

class CommentCrudTest < MiniTest::Spec
  let (:thing) { Thing::Create[thing: {name: "Ruby"}].model }

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


  # # create only works once with unregistered (new) user.
  # it do
  #   op = comment::Create[
  #     rating: {
  #       comment: "Fantastic!",
  #       weight:  1,
  #       user:    {email: "gerd@wurst.com"}
  #     },
  #     id: thing.id
  #   ]

  #   op.unconfirmed?.must_equal true

  #   # second call is invalid!
  #   res, op = Rating::Create.run(
  #     rating: {
  #       comment: "Absolutely amazing!",
  #       weight:  1,
  #       user:    {email: "gerd@wurst.com"}
  #     },
  #     id: thing.id
  #   )

  #   res.must_equal false
  #   op.contract.errors.to_s.must_equal "{:\"user.email\"=>[\"User needs to be confirmed first.\"]}"
  # end
  # # TODO: test registered user (unconfirmed? must always be true).with and without user: {}

  # # delete
  # it do
  #   rating = Rating::Create[
  #     rating: {
  #       comment: "Fantastic!",
  #       weight:  1,
  #       user:    {email: "gerd@wurst.com"}
  #     },
  #     id: thing.id
  #   ].model

  #   Rating::Delete[id: rating.id].must_equal rating

  #   Rating.find(rating.id).deleted.must_equal 1
  # end
end