require 'test_helper'

class HomeIntegrationTest < Trailblazer::Test::Integration
  it do
    Thing.delete_all

    Thing::Create.(thing: {name: "Trailblazer"})
    Thing::Create.(thing: {name: "Descendents"})

    visit "/"

    page.must_have_css ".columns .header a", "Descendents" # TODO: test not-end.
    page.must_have_css ".columns.end .header a", "Trailblazer"
  end
end