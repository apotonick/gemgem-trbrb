require "test_helper"

class SessionSignUpTest < MiniTest::Spec
  # successful.
  it do
    res, op = Session::SignUp.run(user: {
      email: "selectport@trb.org",
      password: "123123",
      confirm_password: "123123",
    })

    op.model.persisted?.must_equal true
    op.model.email.must_equal "selectport@trb.org"

    assert Tyrant::Authenticatable.new(op.model).digest == "123123"
  end

  # not filled out.
  it do
    res, op = Session::SignUp.run(user: {
      email: "",
      password: "",
      confirm_password: "",
    })

    res.must_equal false
    op.model.persisted?.must_equal false
    op.errors.to_s.must_equal "{:email=>[\"can't be blank\", \"is invalid\"], :password=>[\"can't be blank\"], :confirm_password=>[\"can't be blank\"]}"
  end

  # password mismatch.
  it do
    res, op = Session::SignUp.run(user: {
      email: "selectport@trb.org",
      password: "123123",
      confirm_password: "wrong because drunk",
    })

    res.must_equal false
    op.model.persisted?.must_equal false
    op.errors.to_s.must_equal "{:password=>[\"Passwords don't match\"]}"
  end

  # email taken.
  it do
    Session::SignUp.run(user: {
      email: "selectport@trb.org", password: "123123", confirm_password: "123123",
    })

    res, op = Session::SignUp.run(user: {
      email: "selectport@trb.org",
      password: "abcabc",
      confirm_password: "abcabc",
    })

    res.must_equal false
    op.model.persisted?.must_equal false
    op.errors.to_s.must_equal "{:email=>[\"has already been taken\"]}"
  end
end


# this happens when you add a NEW user to a thing.
class SessionSignUpUnconfirmedNeedsPasswordTest < MiniTest::Spec
  it do
    user = User.new( {email: "selectport@trb.org" })

    res, op = Session::SignUp::UnconfirmedNoPassword.run(user: user)

    res.must_equal true

    # user = op.model
    user.email.must_equal "selectport@trb.org"

    Tyrant::Authenticatable.new(user).confirmable?.must_equal true
  end
end