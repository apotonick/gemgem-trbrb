class ThingIntegrationTest < Trailblazer::Test::Integration
  it "allows anonymous" do
    visit "/things/new"

    # everything editable.
    page.must_have_css "form #thing_name"
    page.wont_have_css "form #thing_name.readonly"

    # invalid.
    click_button "Create Thing"
    page.must_have_css ".error"

    # correct submit.
    fill_in 'Name', with: "Rails"
    click_button "Create Thing"
    page.current_path.must_equal thing_path(Thing.last)

    # edit
    thing = Thing.last
    visit "/things/#{thing.id}/edit"
    page.must_have_css "form #thing_name.readonly[value='Rails']"
  end
end