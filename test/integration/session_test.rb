require 'test_helper'

class SessionIntegrationTest < Trailblazer::Test::Integration
  def submit_sign_up!(email, password, confirm)
    within("//form[@id='new_user']") do
      fill_in 'Email',    with: email
      fill_in 'Password', with: password
      fill_in 'Password, again', with: confirm
    end
    click_button "Sign up!"
  end

  it do
    visit "sessions/sign_up_form"

    page.must_have_css "#user_email"
    page.must_have_css "#user_password"
    page.must_have_css "#user_confirm_password"

    # empty
    submit_sign_up!("", "", "")

    page.must_have_css "#user_email"

    # wrong everything.
    submit_sign_up!("wrong", "123", "")
    page.must_have_css "#user_email" # value?

    # password mismatch.
    submit_sign_up!("Scharrels@trb.org", "123", "321")
    page.must_have_css "#user_email" # value?

    submit_sign_up!("Scharrels@trb.org", "123", "123")
    page.must_have_css "#session_email"
    page.must_have_css "#session_password"

  end

  # wrong login.
  it do
    visit "/sessions/sign_in_form"
    # login form is present.
    page.must_have_css "#session_email"
    page.must_have_css "#session_password"

    submit! "vladimir@horowitz.ru", "forgot"

    # login form is present, again.
    page.must_have_css "#session_email"
    page.must_have_css "#session_password"

    # empty login.
    submit! "", ""

    # login form is present, again.
    page.must_have_css "#session_email"
    page.must_have_css "#session_password"
  end

  # sucessful session.
  it do
    visit "sessions/sign_up_form"
    submit_sign_up!("fred@trb.org", "123", "123")
    submit!("fred@trb.org", "123")

    page.must_have_content "Hi, fred@trb.org" # login success.

    # no sign_in screen for logged in.
    visit "/sessions/sign_in_form"
    page.must_have_content "Welcome to Gemgem!"

    # no sign_up screen for logged in.
    visit "/sessions/sign_up_form"
    page.must_have_content "Welcome to Gemgem!"
  end

  # sign_out.
  it do
    visit "sessions/sign_out"
    page.current_path.must_equal "/"
    page.wont_have_content "Hi, fred@trb.org" # login success.

    sign_in!
    page.must_have_content "Hi, fred@trb.org" # login success.

    click_link "Sign out"
    page.current_path.must_equal "/"
    page.wont_have_content "Hi, fred@trb.org" # login success.
  end


  # sign in attempt of unconfirmed-needs-password.
  it do
    Thing::Create.(thing: {name: "Taz", users: [{"email" => "fred@taz.de"}]})

    visit "sessions/sign_in_form"
    submit! "fred@taz.de", ""
    page.wont_have_content "Hi, fred@taz.de" # NO login allowed.
    page.must_have_content "Sign in"
  end


  # non-existent user
  # it do
  #   visit "sessions/wake_up_form/99/?confirmation_token=ALL-WRONG"

  #   page.must_have_content "Welcome"
  # end

  # wrong token for activate.
  it do
    user = Thing::Create.(thing: {name: "Taz", users: [{"email"=> "fred@taz.de"}]}).model.users[0]

    visit "sessions/wake_up_form/#{user.id}/?confirmation_token=ALL-WRONG"

    page.current_path.must_equal "/"
  end

  # sleeping user activates account.
  it do
    user = Thing::Create.(thing: {name: "Taz", users: [{"email"=> "fred@taz.de"}]}).model.users[0]

    token = Tyrant::Authenticatable.new(user).confirmation_token

    visit "sessions/wake_up_form/#{user.id}/?confirmation_token=#{token}"

    page.must_have_content "account, fred@taz.de!"
    page.must_have_css "#user_password"
    page.must_have_css "#user_confirm_password"

    # valid.
    fill_in "Password",        with: "123"
    fill_in "Password, again", with: "123"
    click_button("Engage")

    page.must_have_content "Password changed." # flash.
    user.reload
    Tyrant::Authenticatable.new(user).confirmed?.must_equal true

    page.current_path.must_equal "/sessions/sign_in_form"

    # sign in.
    fill_in "Email", with: "fred@taz.de"
    fill_in "Password", with: "123"
    click_button "Sign in!"

    page.must_have_content "Hi, fred@taz.de"   # signed in.

    # TODO: password mismatch, missing confirmation_token, and so on.

    # # empty
    # submit_sign_up!("", "", "")

    # page.must_have_css "#user_email"

    # # wrong everything.
    # submit_sign_up!("wrong", "123", "")
    # page.must_have_css "#user_email" # value?

    # # password mismatch.
    # submit_sign_up!("Scharrels@trb.org", "123", "321")
    # page.must_have_css "#user_email" # value?

    # submit_sign_up!("Scharrels@trb.org", "123", "123")
    # page.must_have_css "#session_email"
    # page.must_have_css "#session_password"

  end
end
