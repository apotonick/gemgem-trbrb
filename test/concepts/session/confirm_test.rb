require "test_helper"

class SessionConfirmTest < MiniTest::Spec
  let (:user) {
    user = User.create(email: "raff@trb.org")
    Session::SignUp::UnconfirmedNoPassword.(user: user)
    user  }


  describe "#confirmable?" do
    # TODO: add expiry checks.
    it do
      Tyrant::Authenticatable.new(user).confirmable?.must_equal true
    end

    it do
      user = Session::SignUp.(user: {email: "selectport@trb.org", password: "123123", confirm_password: "123123"}).model
      Tyrant::Authenticatable.new(user).confirmable?.must_equal false
    end
  end


  # successful.
  it do
    user = User.create(email: "raff@trb.org")
    Session::SignUp::UnconfirmedNoPassword.(user: user)
    user.save

    user.reload


    op = Session::ChangePassword.(requires_old: false, id: user.id, user: {password: "123", confirm_password: "123"})
    user.reload

    Tyrant::Authenticatable.new(user).confirmed?.must_equal true
    assert Tyrant::Authenticatable.new(user).digest == "123"
  end

  # not-existent id.
  it do
    # Session::Confirm.({id: -1})
  end
end