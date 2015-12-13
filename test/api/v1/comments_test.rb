require "test_helper"

class ApiV1CommentsTest < MiniTest::Spec
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

  describe "GET /comments/1" do
    let (:thing) { Thing::Create.(thing: {name: "Rails"}).model }
    let (:comment) do
      Comment::Create.(
        thing_id:      thing.id,
        comment: {
          body: "Love it!", weight: "1", user: { email: "fred@trb.to" } }
      ).model
    end

    it "renders" do
      get "/api/v1/comments/#{comment.id}"

      last_response.body.must_equal(
        {
          body:   "Love it!",
          weight: 1,
          _embedded: {
            user: {
              email:  "fred@trb.to",
              _links: { self: { href: "/api/v1/users/#{comment.user.id}" } }
            }
          },
          _links: { self: { href: "/api/v1/comments/#{comment.id}" } }
        }.to_json
      )
    end
  end

  describe "POST /api/v1/things/1/comments" do
    let (:thing) { Thing::Create.(thing: {name: "Rails"}).model }
    let (:json)  do
      {
        body:      "Love it!", weight: "1",
        _embedded: { user: { email: "fred@trb.to" } }
      }.to_json
    end

    it do
      post "/api/v1/things/#{thing.id}/comments", json

      comment = thing.comments[0]

      last_response.status.must_equal 201
      last_response.headers["Location"].must_equal "http://example.org/api/v1/comments/#{comment.id}"

      comment.body.must_equal "Love it!"
      comment.weight.must_equal 1
      comment.user.email.must_equal "fred@trb.to"

      # or:

      get "/api/v1/comments/#{comment.id}"

      last_response.body.must_equal(
        {
          body:   "Love it!",
          weight: 1,
          _embedded: {
            user: {
              email:  "fred@trb.to",
              _links: { self: { href: "/api/v1/users/#{comment.user.id}" } }
            }
          },
          _links: { self: { href: "/api/v1/comments/#{comment.id}" } }
        }.to_json
      )
    end
  end
end