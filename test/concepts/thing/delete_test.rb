require "test_helper"

class ThingDeleteTest < MiniTest::Spec
  let (:current_user) { User::Create.(user: {email: "fred@trb.org"}).model }
  let (:admin)        { User::Create.(user: {email: "admin@trb.org"}).model }


  describe "authorless" do
    let (:thing) { Thing::Create.(thing: {name: "Rails"}).model }

    # anonymous
    it "can't be deleted" do
      assert_raises Trailblazer::NotAuthorizedError do
        Thing::Delete.(id: thing.id)
      end
    end

    # signed in.
    it "can't be deleted" do
      assert_raises Trailblazer::NotAuthorizedError do
        Thing::Delete.(id: thing.id, current_user: current_user)
      end
    end

    # admin
    it "can be deleted as admin" do
      deleted = Thing::Delete.(id: thing.id, current_user: admin).model
      deleted.destroyed?.must_equal true
    end
  end


  describe "with authors" do
    let (:thing) { Thing::Create::SignedIn.(thing: {name: "Rails", users: [{"email"=>"joe@trb.org"}]}).model }

    # anonymous
    it "can't be deleted" do
      assert_raises Trailblazer::NotAuthorizedError do
        Thing::Delete.(id: thing.id)
      end
    end

    # signed in, not author
    it "can't be deleted because we're not author" do
      thing = Thing::Create.(thing: {name: "Rails", users: [{"email"=>"joe@trb.org"}]}, current_user: current_user).model

      assert_raises Trailblazer::NotAuthorizedError do
        Thing::Delete.(id: thing.id, current_user: current_user)
      end
    end

    # signed in is author
    it "deleted by author, no image, no comments" do
      thing = Thing::Create.(thing: {name: "Rails", is_author: "1"}, current_user: current_user).model
      thing = Thing::Delete.(id: thing.id, current_user: current_user).model
      thing.destroyed?.must_equal true
    end

    # admin
    it "deleted by admin" do
      thing = Thing::Create.(thing: {name: "Rails", is_author: "1"}, current_user: current_user).model
      thing = Thing::Delete.(id: thing.id, current_user: admin).model
      thing.destroyed?.must_equal true
    end



    # edge-case: with image.
    it "deleted by author, with images and comments" do
      thing = Thing::Create.(thing: {name: "Rails", is_author: "1", file: File.open("test/images/cells.jpg")}, current_user: current_user).model

      file = Thing::Cell::Decorator.new(thing)

      thing = Thing::Delete.(id: thing.id, current_user: current_user).model
      thing.destroyed?.must_equal true

      # image must be deleted, too.
      file = Thing::Cell::Decorator.new(thing)
      File.exists?("public#{file.image[:thumb].url}").must_equal false
      File.exists?("public#{file.image[:original].url}").must_equal false
      # Paperdragon::Attachment.new(thing.image_meta_data).exists?.must_equal true
    end
  end
end