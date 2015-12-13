require "test_helper"

class ApiV1ThingsTest < MiniTest::Spec
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def post(uri, data)
    super(uri, data, "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json")
  end
  def patch(uri, data)
    super(uri, data, "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json")
  end

  def get(uri)
    super(uri, nil, "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json")
  end

  describe "GET" do
    it do
      id = Thing::Create.(thing: {name: "Rails"}).model.id
      get "/api/v1/things/#{id}"
      last_response.body.must_equal %{{"name":"Rails","_embedded":{"comments":[]},"_links":{"self":{"href":"/api/v1/things/#{id}"}}}}
    end

    it "shows authors" do
      id = Thing::Create.(thing: {name: "Rails", users: [{email: "fred@trb.to"}]}).model.id
      get "/api/v1/things/#{id}"
      last_response.body.must_equal %{{"name":"Rails","_embedded":{"comments":[]},"_links":{"self":{"href":"/api/v1/things/#{id}"}}}}
    end
  end

  describe "POST" do
    it "post" do
      post "/api/v1/things/", { name: "Lotus" }.to_json
      id = Thing.last.id

      last_response.headers["Location"].must_equal "http://example.org/api/v1/things/#{id}"
      assert last_response.created?
      last_response.body.must_equal %{{"name":"Lotus","_links":{"self":{"href":"/api/v1/things/#{id}"}}}}
    end

    it "POST allows adding authors yyy" do
      json = {
        name:      "Lotus",
        _embedded: { authors: [{ email: "fred@trb.org" }] }
        }.to_json

      post "/api/v1/things/", json

      id = Thing.last.id
      author_id = Thing.last.users.first.id

      last_response.headers["Location"].must_equal "http://example.org/api/v1/things/#{id}"
      assert last_response.created?
      last_response.body.must_equal %{{"name":"Lotus","_embedded":{"authors":[{"email":"fred@trb.org","_links":{"self":{"href":"/api/v1/users/#{author_id}"}}}]},"_links":{"self":{"href":"/api/v1/things/#{id}"}}}}
    end
  end

  describe "PATCH /api/v1/things/1" do
    it "does not allow to edit for anonymous" do
      thing = Thing::Create.(thing: {name: "Lotus", users: [{"email"=> "jacob@trb.org"}]}).model
      id = thing.id
      author_id = thing.users.first.id

      data = {_embedded: { authors: [{id: "#{author_id}", remove: "1"}] }, is_author: "0"}
      patch "/api/v1/things/#{id}/", data.to_json

      get "/api/v1/things/#{id}"
      last_response.body.must_equal %{{"name":"Lotus","_embedded":{"authors":[{"email":"jacob@trb.org","_links":{"self":{"href":"/api/v1/users/#{author_id}"}}}],"comments":[]},"_links":{"self":{"href":"/api/v1/things/#{id}"}}}}
    end

    it "allows update for admin" do
      thing = Thing::Create.(thing: {name: "Lotus", users: [{"email"=> "jacob@trb.org"}]}).model
      id = thing.id
      author_id = thing.users.first.id

      data = {name: "Roda", _embedded: { authors: [{id: "#{author_id}", remove: "1"}] }, is_author: "0"}

      Session::SignUp::Admin.(user: {email: "admin@trb.org", password: "123456"})
      authorize("admin@trb.org", "123456")
      patch "/api/v1/things/#{id}/", data.to_json

      get "/api/v1/things/#{id}"
      last_response.body.must_equal %{{"name":"Roda","_embedded":{"comments":[]},"_links":{"self":{"href":"/api/v1/things/#{id}"}}}}
    end
  end

  describe "GET /things" do
    it "shows authors and comments per default" do
      jacobs_thing = Thing::Create.(thing: {name: "Lotus", users: [{"email"=> "jacob@trb.to"}]}).model
      dhhs_thing   = Thing::Create.(thing: {name: "Rails", users: [{"email"=> "dhh@trb.to"}]}).model
      comment      = Comment::Create.(thing_id: dhhs_thing.id, comment: {body: "I like his stuff!", weight: "1", user: {email: "jose@trb.to"}}).model
      robs_thing   = Thing::Create.(thing: {name: "TRB", users:   [{"email"=> "rob@trb.to"}]}).model

      get "/api/v1/things"
       # pp JSON[last_response.body]

      JSON[last_response.body].must_equal (
        {"_embedded"=>
          {"things"=>
            [{"name"=>"TRB",
              "_embedded"=>
              {"authors"=>
                [{"email"=>"rob@trb.to",
                  "_links"=>{"self"=>{"href"=>"/api/v1/users/#{robs_thing.users[0].id}"}}}],
                "comments"=>[]},
              "_links"=>{"self"=>{"href"=>"/api/v1/things/#{robs_thing.id}"}}},
             {"name"=>"Rails",
              "_embedded"=>
                {"authors"=>
                  [{"email"=>"dhh@trb.to",
                    "_links"=>{"self"=>{"href"=>"/api/v1/users/#{dhhs_thing.users[0].id}"}}}],
                "comments"=>
                  [{"body"=>"I like his stuff!",
                    "weight"=>1,
                    "_embedded"=>{"user"=>{"email"=>"jose@trb.to", "_links"=>{"self"=>{"href"=>"/api/v1/users/#{dhhs_thing.comments[0].user.id}"}}}},
                  "_links"=>{"self"=>{"href"=>"/api/v1/comments/#{dhhs_thing.comments[0].id}"}}}]},
              "_links"=>{"self"=>{"href"=>"/api/v1/things/#{dhhs_thing.id}"}}},
             {"name"=>"Lotus",
              "_embedded"=>
                {"authors"=>
                  [{"email"=>"jacob@trb.to",
                    "_links"=>{"self"=>{"href"=>"/api/v1/users/#{jacobs_thing.users[0].id}"}}}],
                "comments"=>[]},
              "_links"=>{"self"=>{"href"=>"/api/v1/things/#{jacobs_thing.id}"}}}]},
        "_links"=>{"self"=>{"href"=>"/api/v1/things"}}}
      )
    end

    it "displays authors, only" do
      jacobs_thing = Thing::Create.(thing: {name: "Lotus", users: [{"email"=> "jacob@trb.to"}]}).model
      dhhs_thing   = Thing::Create.(thing: {name: "Rails", users: [{"email"=> "dhh@trb.to"}]}).model
      comment      = Comment::Create.(thing_id: dhhs_thing.id, comment: {body: "I like his stuff!", weight: "1", user: {email: "jose@trb.to"}}).model
      robs_thing   = Thing::Create.(thing: {name: "TRB", users:   [{"email"=> "rob@trb.to"}]}).model

      get "/api/v1/things?include=users"
       # pp JSON[last_response.body]
      JSON[last_response.body].must_equal ({
        "_embedded"=>
          {"things"=>
            [{"name"=>"TRB",
              # "id"=>3,
              "_embedded"=>
               {"authors"=>
                 [{"email"=>"rob@trb.to",
                   # "id"=>3,
                   "_links"=>{"self"=>{"href"=>"/api/v1/users/#{robs_thing.users[0].id}"}}}]},
              "_links"=>{"self"=>{"href"=>"/api/v1/things/#{robs_thing.id}"}}},
             {"name"=>"Rails",
              # "id"=>2,
              "_embedded"=>
               {"authors"=>
                 [{"email"=>"dhh@trb.to",
                   # "id"=>2,
                   "_links"=>{"self"=>{"href"=>"/api/v1/users/#{dhhs_thing.users[0].id}"}}}]},
              "_links"=>{"self"=>{"href"=>"/api/v1/things/#{dhhs_thing.id}"}}},
             {"name"=>"Lotus",
              # "id"=>1,
              "_embedded"=>
               {"authors"=>
                 [{"email"=>"jacob@trb.to",
                   # "id"=>1,
                   "_links"=>{"self"=>{"href"=>"/api/v1/users/#{jacobs_thing.users[0].id}"}}}]},
              "_links"=>{"self"=>{"href"=>"/api/v1/things/#{jacobs_thing.id}"}}}]},
         "_links"=>{"self"=>{"href"=>"/api/v1/things"}}})
    end

    it "includes comments, only" do
      jacobs_thing = Thing::Create.(thing: {name: "Lotus", users: [{"email"=> "jacob@trb.to"}]}).model
      dhhs_thing   = Thing::Create.(thing: {name: "Rails", users: [{"email"=> "dhh@trb.to"}]}).model
      comment      = Comment::Create.(thing_id: dhhs_thing.id, comment: {body: "I like his stuff!", weight: "1", user: {email: "jose@trb.to"}}).model
      robs_thing   = Thing::Create.(thing: {name: "TRB", users:   [{"email"=> "rob@trb.to"}]}).model

      get "/api/v1/things?include=comments"
       # pp JSON[last_response.body]
      JSON[last_response.body].must_equal (
        {"_embedded"=>
          {"things"=>
            [{"name"=>"TRB",
              "_embedded"=>
              {"comments"=>[]},
              "_links"=>{"self"=>{"href"=>"/api/v1/things/#{robs_thing.id}"}}},
             {"name"=>"Rails",
              "_embedded"=>
                {"comments"=>
                  [{"body"=>"I like his stuff!", "weight"=>1, "_embedded"=>{"user"=>{"email"=>"jose@trb.to", "_links"=>{"self"=>{"href"=>"/api/v1/users/#{dhhs_thing.comments[0].user.id}"}}}},
                  "_links"=>{"self"=>{"href"=>"/api/v1/comments/#{dhhs_thing.comments[0].id}"}}}]},
              "_links"=>{"self"=>{"href"=>"/api/v1/things/#{dhhs_thing.id}"}}},
             {"name"=>"Lotus",
              "_embedded"=>
                {"comments"=>[]},
              "_links"=>{"self"=>{"href"=>"/api/v1/things/#{jacobs_thing.id}"}}}]},
        "_links"=>{"self"=>{"href"=>"/api/v1/things"}}}
      )
    end

    describe "sort" do
      it "sort=recent" do
        things = 20.times.collect { |i| Thing::Create.(thing: {name: "Thing #{i}", users: [{"email"=> "#{i}@trb.to"}]}).model }

        get "/api/v1/things?include="
       # pp JSON[last_response.body]

        JSON[last_response.body].must_equal(
          {
            "_embedded"=>
              {
                "things"=>
                  things.reverse[0..8].collect { |t| {"name"=>"#{t.name}", "_links"=>{"self"=>{"href"=>"/api/v1/things/#{t.id}"}}} }
              },
            "_links"=>{"self"=>{"href"=>"/api/v1/things"}}}
          )
      end

      it "sort=oldest" do
        things = 20.times.collect { |i| Thing::Create.(thing: {name: "Thing #{i}", users: [{"email"=> "#{i}@trb.to"}]}).model }

        get "/api/v1/things?include=&sort=oldest"
       # pp JSON[last_response.body]

        JSON[last_response.body].must_equal(
          {
            "_embedded"=>
              {
                "things"=>
                  things[0..8].collect { |t| {"name"=>"#{t.name}", "_links"=>{"self"=>{"href"=>"/api/v1/things/#{t.id}"}}} }
              },
            "_links"=>{"self"=>{"href"=>"/api/v1/things?sort=oldest"}}}
          )
      end
    end
  end
end

# FIXME: representer(include: [:users, :comments]) to exclude image_meta_data etc.