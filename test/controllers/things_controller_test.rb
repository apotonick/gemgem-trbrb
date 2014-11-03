require 'test_helper'

describe ThingsController do
  let (:thing) { Thing::Create[thing: {name: "Trailblazer"}].model }

  describe "#new" do
    it "#new [HTML]" do
      get :new
      assert_select "form #thing_name"
    end
  end

  # create
  describe "#create" do
    it "HTML, valid" do
      post :create, {thing: {name: "Bad Religion"}}
      assert_redirected_to thing_path(Thing.last)
    end

    it do # invalid.
      post :create, {thing: {name: ""}}
      assert_select ".error"
    end
  end

  describe "#edit" do
    # edit
    it do
      get :edit, id: thing.id
      assert_select "form #thing_name[value='Trailblazer']"
    end
  end

  describe "#update" do
    it do
      put :update, id: thing.id, thing: {name: "Trb"}
      assert_redirected_to thing_path(thing)
      # assert_select "h1", "Trb"
    end

    it do
      put :update, id: thing.id, thing: {name: nil}
      assert_select ".error"
    end
  end

  describe "#show" do
    it "HTML" do
      get :show, id: thing.id
      response.body.must_match /Trailblazer/
    end

    it "JSON" do
      get :show, id: thing.id, format: :json
      response.body.must_equal "{\"name\":\"Trailblazer\",\"_links\":{\"self\":{\"href\":\"/things/1\"}}}"
    end
  end
end