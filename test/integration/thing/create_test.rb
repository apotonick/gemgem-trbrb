require "test_helper"

class ThingsControllerCreateTest < Trailblazer::Test::Integration
  # let (:thing) do
  #   thing = Thing::Create.(thing: {name: "Rails"}).model

  #   Comment::Create.(comment: {body: "Excellent", weight: "0", user: {email: "zavan@trb.org"}}, id: thing.id)
  #   Comment::Create.(comment: {body: "!Well.", weight: "1", user: {email: "jonny@trb.org"}}, id: thing.id)
  #   Comment::Create.(comment: {body: "Cool stuff!", weight: "0", user: {email: "chris@trb.org"}}, id: thing.id)
  #   Comment::Create.(comment: {body: "Improving.", weight: "1", user: {email: "hilz@trb.org"}}, id: thing.id)

  #   thing
  # end

  def assert_new_form
    page.must_have_css "form #thing_name"
    page.wont_have_css "form #thing_name.readonly"

    # 3 author email fields.
    page.must_have_css("input.email", count: 3) # TODO: how can i say "no value"?
  end


  describe "#new" do
    # anonymous
    it do
      visit "/things/new"

      assert_new_form
      page.wont_have_css("#thing_is_author")

      # no orange background.
      page.wont_have_css("form.admin")
    end

    # signed-in.
    it do
      sign_in!

      visit "/things/new"
      assert_new_form
      page.must_have_css("#thing_is_author")
      page.wont_have_css("form.admin") # no orange background.
    end

    # admin.
    it do
      sign_in!("admin@trb.org", "123")
      visit "/things/new"

      assert_new_form
      page.must_have_css("#thing_is_author")

      # orange background!
      page.must_have_css("form.admin")
    end
  end


  describe "lifecycle" do
    # anonymous.
    it do
      visit "/things/new"

      # invalid.
      click_button "Create Thing"
      page.must_have_css ".error"
      page.must_have_css("input.email", count: 3) # 3 author email fields

      # correct submit.
      fill_in 'Name', with: "Bad Religion"
      click_button "Create Thing"
      page.current_path.must_equal thing_path(Thing.last)

      # edit
      page.wont_have_css "a", text: "Edit"
      page.wont_have_css "a", text: "Delete"
    end

    # signed-in.
    it do
      sign_in!
      visit "/things/new"

      # invalid.
      click_button "Create Thing"
      page.must_have_css ".error"

      # correct submit.
      fill_in 'Name', with: "Bad Religion"
      check "I'm the author!"
      click_button "Create Thing"
      # /things/1
      page.current_path.must_equal thing_path(Thing.last)
      page.must_have_content "By fred@trb.org"

      # edit
      click_link "Edit" # /things/1/edit
      page.must_have_css "form #thing_name"
      page.must_have_css "form #thing_name.readonly"

      # update
      fill_in "Description", with: "Great band"
      click_button "Update Thing"
      page.current_path.must_equal thing_path(Thing.last)
      page.must_have_content "Great band"

      # remove author.
      # Remove signed in author.
      click_link "Edit"

      # check "I'm the author!"
      check("Remove")
      click_button "Update Thing"

      page.current_path.must_equal thing_path(Thing.last)
      page.wont_have_content "By fred@trb.org"
    end

    # admin.
    it do
    sign_in!("admin@trb.org")
      visit "/things/new"

      # invalid.
      click_button "Create Thing"
      page.must_have_css ".error"

      # correct submit.
      fill_in 'Name', with: "Bad Religion"
      check "I'm the author!"
      click_button "Create Thing"
      # /things/1
      page.current_path.must_equal thing_path(Thing.last)
      page.must_have_content "By admin@trb.org"

      # edit
      click_link "Edit" # /things/1/edit
      page.must_have_css "form #thing_name"
      page.wont_have_css "form #thing_name.readonly"

      # update
      fill_in "Description", with: "Great band"
      click_button "Update Thing"
      page.current_path.must_equal thing_path(Thing.last)
      page.must_have_content "Great band"

      # remove author.
      # Remove signed in author.
      click_link "Edit"

      # check "I'm the author!"
      check("Remove")
      click_button "Update Thing"

      page.current_path.must_equal thing_path(Thing.last)
      page.wont_have_content "By admin@trb.org"

      click_link "Delete"
      page.current_path.must_equal root_path
    end
  end


  # describe "authorization exceptions" do
  #   let(:user)  { User::Create.(user: {email: "fred@trb.org"}).model }
  #   let(:thing) { Thing::Create.(thing: {name: "Rails"}, current_user: user).model }

  #   # anonymous
  #   it do
  #     visit "/things/#{thing.id}/edit"
  #     page.current_path.must_equal "/" # policy breach.
  #   end

  #   # signed-in
  #   it do
  #     sign_in!
  #     visit "/things/#{thing.id}/edit"
  #     page.must_have_css "form" # author is current_user.
  #   end
  # end
end
