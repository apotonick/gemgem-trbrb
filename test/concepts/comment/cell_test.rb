require 'test_helper'

class CommentCellTest < Cell::TestCase
  controller ThingsController

  let (:thing) { Thing::Create.(thing: {name: "Rails"}).model }

  before do
    Comment::Create.(comment: {body: "Excellent", weight: "0", user: {email: "zavan@trb.org"}}, thing_id: thing.id)
    Comment::Create.(comment: {body: "!Well.", weight: "1", user: {email: "jonny@trb.org"}}, thing_id: thing.id)
    Comment::Create.(comment: {body: "Cool stuff!", weight: "0", user: {email: "chris@trb.org"}}, thing_id: thing.id)
    Comment::Create.(comment: {body: "Improving.", weight: "1", user: {email: "hilz@trb.org"}}, thing_id: thing.id)
  end

  # the comment grid.
  # .(:show)
  it do
    html = concept("comment/cell/grid", thing).(:show)

    comments = html.all(:css, ".comment")
    comments.size.must_equal 3

    first = comments[0]
    puts first.find(".header").class
    first.find(".header").must_have_content "hilz@trb.org"
    first.find(".header time")["datetime"].must_match /\d\d-/
    first.must_have_content "Improving"
    first.wont_have_selector(".fi-heart")
    first[:class].wont_match /\send/

    second = comments[1]
    second.find(".header").must_have_content "chris@trb.org"
    second.find(".header time")["datetime"].must_match /\d\d-/
    second.must_have_content "Cool stuff!"
    second.must_have_selector(".fi-heart")
    second[:class].wont_match /\send/

    third = comments[2]
    third.find(".header").must_have_content "jonny@trb.org"
    third.find(".header time")["datetime"].must_match /\d\d-/
    third.must_have_content "!Well."
    third.wont_have_selector(".fi-heart")
    third[:class].must_match /\send/ # last grid item.

    # "More!"
    html.find("#next a")["href"].must_equal "/things/#{thing.id}/next_comments?page=2"
  end

  # .(:append)
  it do
    html = concept("comment/cell/grid", thing, page: 2).(:append)

    html.to_s.must_match /replaceWith/
    html.to_s.must_match /zavan@trb.org/
  end
end