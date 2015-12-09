describe "#create_comment" do
    it "invalid" do
      post :create_comment, id: thing.id,
        comment: {body: "invalid!"}

      assert_select ".comment_user_email.error"
    end

    it do
      post :create_comment, id: thing.id,
        comment: {body: "That green jacket!", weight: "1", user: {email: "seuros@trb.org"}}

      assert_redirected_to thing_path(thing)
      flash[:notice].must_equal "Created comment for \"Rails\""
    end
  end

  describe "#next_comments" do
    it do
      xhr :get, :next_comments, id: thing.id, page: 2

      response.body.must_match /zavan@trb.org/
    end
  end