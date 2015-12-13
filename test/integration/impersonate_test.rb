require "test_helper"

class SessionImpersonateTest < Trailblazer::Test::Integration
  let (:jimmy) { User::Create.(user: {email: "jimmy@trb.org"}) }
  before { jimmy }

  # anonymous can't.
  it do
    visit "/?as=jimmy@trb.org"
    # submit_sign_up!("fred@trb.org", "123", "123")
    # submit!("fred@trb.org", "123")

    page.must_have_css "a", text: "Sign in" # not logged in.
  end

  # signed-in can't.
  it do
    sign_in!
    visit "/?as=jimmy@trb.org"
    page.must_have_content "Hi, fred@trb.org" # signed-in but no impersonation.
  end

  # admin can.
  it do
    sign_in!("admin@trb.org", "123456")
    visit "/?as=jimmy@trb.org"
    page.must_have_content "Hi, jimmy@trb.org" # signed-in but no impersonation.
  end
end