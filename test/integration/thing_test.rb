require "test_helper"

class ThingIntegrationTest < Trailblazer::Test::Integration
  it "allows anonymous" do
    visit "/things/new"

    # everything editable.
    page.must_have_css "form #thing_name"
    page.wont_have_css "form #thing_name.readonly"

    # 3 author email fields
    page.must_have_css("input.email", count: 3) # TODO: how can i say "no value"?

    # invalid.
    click_button "Create Thing"
    page.must_have_css ".error"
    # 3 author email fields
    page.must_have_css("input.email", count: 3)

    # correct submit.
    fill_in 'Name', with: "Rails"
    click_button "Create Thing"

    # show
    page.current_path.must_equal thing_path(Thing.last)
    page.body.must_match /Rails/
    # comment form in show
    page.must_have_css "input.button[value='Create Comment']"
    page.must_have_css ".comment_user_email"
    page.must_have_css ".comments" # grid.

    # edit
    thing = Thing.last
    visit "/things/#{thing.id}/edit"
    page.wont_have_css "form #thing_name"
  end
end