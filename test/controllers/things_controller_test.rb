require 'test_helper'

describe ThingsController do
  let (:thing) { Thing::Create[thing: {name: "Trailblazer"}].model }

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
      assert_select "form #thing_name.readonly[value='Trailblazer']"
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
    it "HTML" do
      get :show, id: thing.id
      response.body.must_match /Trailblazer/

       # the form. this assures the model_name is properly set.
      assert_select "input.button[value=?]", "Create Comment"
      # make sure the user form is displayed.
      assert_select ".comment_user_email"
    end
  end

  describe "#create_comment" do
    it do
      post :create_comment, id: thing.id,
        comment: {body: "That green jacket!", weight: "1", user: {email: "seuros@trb.org"}}

      assert_redirected_to thing_path(thing)
    end
  end
end