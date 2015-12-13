require "test_helper"

class ThingsControllerUpdateTest < Trailblazer::Test::Integration
  def assert_edit_form
    page.must_have_css "#thing_users_attributes_0_remove"
    # empty email for new.
    page.must_have_css "#thing_users_attributes_1_email"
    # no remove for new.
    page.wont_have_css "#thing_users_attributes_1_remove"
  end

  let (:thing_with_fred) do
    thing = Thing::Create.(thing: {name: "Rails", users: [{"email" => "fred@trb.org"}]}).model

    Comment::Create.(comment: {body: "Excellent", weight: "0", user: {email: "zavan@trb.org"}}, thing_id: thing.id)
    Comment::Create.(comment: {body: "!Well.", weight: "1", user: {email: "jonny@trb.org"}}, thing_id: thing.id)
    Comment::Create.(comment: {body: "Cool stuff!", weight: "0", user: {email: "chris@trb.org"}}, thing_id: thing.id)
    Comment::Create.(comment: {body: "Improving.", weight: "1", user: {email: "hilz@trb.org"}}, thing_id: thing.id)

    thing
  end


  describe "#edit" do
    # anonymous
    it "doesn't work with not signed-in" do
      visit "/things/#{thing_with_fred.id}/edit"
      page.current_path.must_equal "/"
    end

    # signed-in
    it do
      sign_in!
      visit "/things/#{thing_with_fred.id}/edit"

      page.wont_have_css "form.admin"
      page.must_have_css "form #thing_name.readonly[value='Rails']"
      # existing email is readonly.
      page.must_have_css "#thing_users_attributes_0_email.readonly[value='fred@trb.org']"
      # remove button for existing.
      assert_edit_form
    end

    # admin
    it do
      sign_in!("admin@trb.org")
      visit "/things/#{thing_with_fred.id}/edit"

      page.must_have_css "form.admin"
      page.wont_have_css "form #thing_name.readonly"
      page.must_have_css "form #thing_name[value='Rails']"
      # existing email is readonly.
      page.must_have_css "#thing_users_attributes_0_email.readonly[value='fred@trb.org']"
      # remove button for existing.
      assert_edit_form
    end
  end
end