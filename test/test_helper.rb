ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require "minitest/autorun"
require "trailblazer/rails/test/integration"

Rails.backtrace_cleaner.remove_silencers!

Minitest::Spec.class_eval do
  after :each do
    # DatabaseCleaner.clean
    Thing.delete_all
    Comment.delete_all
    User.delete_all
  end
end

Cell::TestCase.class_eval do
  include Capybara::DSL
  include Capybara::Assertions
end

Trailblazer::Test::Integration.class_eval do
  def sign_in!(email="fred@trb.org", password="123456")
    sign_up!(email, password) #=> Session::SignUp

    visit "/sessions/sign_in_form"

    submit!(email, password)
  end

  def sign_up!(email="fred@trb.org", password="123456")
    Session::SignUp::Admin.(user: {email: email, password: password})
  end

  def submit!(email, password)
    within("//form[@id='new_session']") do
      fill_in 'Email',    with: email
      fill_in 'Password', with: password
    end
    click_button "Sign in!"
  end
end