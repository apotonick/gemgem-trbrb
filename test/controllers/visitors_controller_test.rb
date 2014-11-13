require 'test_helper'

class IntegrationTest < ActionDispatch::IntegrationTest
  it do
    Thing.delete_all

    Thing::Create[thing: {name: "Trailblazer"}]
    Thing::Create[thing: {name: "Descendents"}]

    get "/"

    assert_select ".columns .header a", "Descendents" # TODO: test not-end.
    assert_select ".columns.end .header a", "Trailblazer"
  end
end