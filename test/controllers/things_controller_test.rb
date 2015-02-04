require 'test_helper'

describe ThingsController do
  # let (:thing) { Thing::Create[thing: {name: "Trailblazer"}].model }
  let (:thing) do
    thing = Thing::Create[thing: {name: "Rails"}].model

    Comment::Create[comment: {body: "Excellent", weight: "0", user: {email: "zavan@trb.org"}}, id: thing.id]
    Comment::Create[comment: {body: "!Well.", weight: "1", user: {email: "jonny@trb.org"}}, id: thing.id]
    Comment::Create[comment: {body: "Cool stuff!", weight: "0", user: {email: "chris@trb.org"}}, id: thing.id]
    Comment::Create[comment: {body: "Improving.", weight: "1", user: {email: "hilz@trb.org"}}, id: thing.id]

    thing
  end

  describe "#new" do
    it "#new [HTML]" do
      # TODO: please make Capybara matchers work with this!
      get :new
      assert_select "form #thing_name"
      assert_select "form #thing_name.readonly", false
    end
  end

  describe "#create" do
    it do
      post :create, {thing: {name: "Bad Religion"}}
      assert_redirected_to thing_path(Thing.last)
    end

    it do # invalid.
      post :create, {thing: {name: ""}}
      assert_select ".error"
    end
  end

  describe "#edit" do
    it do
      get :edit, id: thing.id
      assert_select "form #thing_name.readonly[value='Rails']"
    end
  end

  describe "#update" do
    it do
      put :update, id: thing.id, thing: {name: "Trb"}
      assert_redirected_to thing_path(thing)
      # assert_select "h1", "Trb"
    end

    it do
      put :update, id: thing.id, thing: {description: "bla"}
      assert_select ".error"
    end
  end

  describe "#show" do
    it do
      get :show, id: thing.id
      response.body.must_match /Rails/

       # the form. this assures the model_name is properly set.
      assert_select "input.button[value=?]", "Create Comment"
      # make sure the user form is displayed.
      assert_select ".comment_user_email"
      # comments must be there.
      assert_select ".comments .comment"
    end
  end

  describe "#create_comment" do
    it "invalid" do
      post :create_comment, id: thing.id,
        comment: {body: "invalid!"}

      assert_select ".comment_user_email.error"
    end

    it do
      post :create_comment, id: thing.id,
        comment: {body: "That green jacket!", weight: "1", user: {email: "seuros@trb.org"}}

      assert_redirected_to thing_path(thing)
      flash[:notice].must_equal "Created comment for \"Rails\""
    end
  end

  describe "#next_comments" do
    it do
      xhr :get, :next_comments, id: thing.id, page: 2

      response.body.must_match /zavan@trb.org/
    end
  end
end