require "test_helper"

class CommentIntegrationTest < Trailblazer::Test::Integration
  let (:thing) { Thing::Create.(thing: {name: "Rails"}).model }

  before do
    Comment::Create.(comment: {body: "Excellent", weight: "0", user: {email: "zavan@trb.org"}}, thing_id: thing.id)
    Comment::Create.(comment: {body: "!Well.", weight: "1", user: {email: "jonny@trb.org"}}, thing_id: thing.id)
    Comment::Create.(comment: {body: "Cool stuff!", weight: "0", user: {email: "chris@trb.org"}}, thing_id: thing.id)
    Comment::Create.(comment: {body: "Improving.", weight: "1", user: {email: "hilz@trb.org"}}, thing_id: thing.id)
  end

  describe "#create_comment" do
    it "is invalid" do
      visit "/things/#{thing.id}"

      fill_in "Your comment", with: "invalid"
      click_button "Create Comment"

      page.must_have_css ".comment_user_email.error"
    end

    # anonymous/
    it "works" do
      visit "/things/#{thing.id}"

      # allows unregistered comment.
      page.must_have_css "#comment_user_attributes_email"

      fill_in "Your comment", with: "That green jacket!"
      choose "Nice!"
      fill_in "Your email", with: "seuros@trb.to"
      click_button "Create Comment"

      page.current_path.must_equal "/things/#{thing.id}"
      page.must_have_css ".alert-box", text: "Created comment for \"Rails\""
    end
  end

  describe "#next_comments" do
    it do
      visit thing_path(thing.id)
      # xhr :get, :next_comments, id: thing.id, page: 2
      click_link "More!"

      page.must_have_content /zavan@trb.org/
    end
  end
end