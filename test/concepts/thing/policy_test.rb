require "test_helper"

class ThingPolicyTest < MiniTest::Spec
  let (:author) { User::Create.(user: {email: "jd@trb.org"}).model }
  let (:thing) { Thing::Create.(thing: {name: "Bad Religion", users: [{"email" => author.email}]}).model }

  let (:policy) { Thing::Update.policy_config.(user, thing) }


  describe "NOT signed in" do
    let (:user) { nil }
    it { policy.update?.must_equal false }
  end

  describe "signed in" do
    let (:user) { User::Create.(user: {email: "jimmy@trb.com"}).model }
    it { policy.update?.must_equal false }
    # is author
    it do
      policy = Thing::Update.policy_config.(author, thing)
      policy.update?.must_equal true
    end

    # not author
    it do
      policy = Thing::Update.policy_config.(user, thing)
      policy.update?.must_equal false
    end
  end

  describe "admin" do
    let (:admin) { User::Create.(user: {"email"=> "admin@trb.org"}).model }

    # is author
    it do
      thing  = Thing::Create.(thing: {name: "Bad Religion", users: [{"email"=>admin.email}]}).model
      policy = Thing::Update.policy_config.(admin, thing)

      policy.update?.must_equal true
    end

    # not author
    it do
      policy = Thing::Update.policy_config.(admin, thing)
      policy.update?.must_equal true
    end
  end
end