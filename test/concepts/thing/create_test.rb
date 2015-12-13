require "test_helper"

class ThingCreateTest < MiniTest::Spec
  let (:current_user) { User::Create.(user: {email: "fred@trb.org"}).model }
  let (:admin)        { User::Create.(user: {email: "admin@trb.org"}).model }

  it "rendering" do # DISCUSS: not sure if that will stay here, but i like the idea of presentation/logic in one place.
    form = Thing::Create.present({}).contract
    form.prepopulate! # this is a bit of an API breach.

    form.users.size.must_equal 3 # always offer 3 user emails.
    form.users[0].email.must_equal nil
    form.users[1].email.must_equal nil
    form.users[2].email.must_equal nil
  end

  it "persists valid" do
    thing = Thing::Create[thing: {name: "Rails", description: "Kickass web dev"}].model

    thing.persisted?.must_equal true
    thing.name.must_equal "Rails"
    thing.description.must_equal "Kickass web dev"
  end

  # valid file upload.
  it "valid upload" do
    thing = Thing::Create.(thing: {name: "Rails",
      file: File.open("test/images/cells.jpg")}).model

    Paperdragon::Attachment.new(thing.image_meta_data).exists?.must_equal true
  end

  it "hack" do
    thing = Thing::Create.(thing: {name: "Rails",
      image_meta_data: {bla: 1}}).model
    thing.image_meta_data.must_equal nil
  end

  # invalid file upload.
  it "invalid upload" do
    res, op = Thing::Create.run(thing: {name: "Rails",
      file: File.open("test/images/hack.pdf")})

    res.must_equal false
    op.errors.to_s.must_equal "{:file=>[\"file has an extension that does not match its contents\", \"file should be one of image/jpeg, image/png\"]}"
  end

  it "invalid" do
    res, op = Thing::Create.run(thing: {name: ""})

    res.must_equal false
    op.errors.to_s.must_equal "{:name=>[\"can't be blank\"]}"
    op.model.persisted?.must_equal false

    op.invocations[:default].must_equal nil
  end

  it "invalid description" do
    res, op = Thing::Create.run(thing: {name: "Rails", description: "hi"})

    res.must_equal false
    op.errors.to_s.must_equal "{:description=>[\"is too short (minimum is 4 characters)\"]}"
  end

  # users
  it "invalid email" do
    res, op = Thing::Create.run(thing: {name: "Rails", users: [{"email"=>"invalid format"}, {"email"=>"bla"}]})

    res.must_equal false
    op.errors.to_s.must_equal "{:\"users.email\"=>[\"is invalid\"]}"

    # still 3 users
    form = op.contract
    form.prepopulate! # FIXME: hate this. move prepopulate! to Op#run.

    form.users.size.must_equal 3 # always offer 3 user emails.
    form.users[0].email.must_equal "invalid format"
    form.users[1].email.must_equal "bla"
    form.users[2].email.must_equal nil # this comes from prepopulate!
  end

  # all emails blank
  it "all emails blank" do
    res, op = Thing::Create.run(thing: {name: "Rails", users: [{"email"=>""}]})

    res.must_equal true
    op.model.users.must_equal []
  end

  it "valid, new and existing email xxx" do
    solnic = User.create(email: "solnic@trb.org") # TODO: replace with operation, once we got one.
    User.count.must_equal 1

    op    = Thing::Create.(thing: {name: "Rails", users: [{"email"=>"solnic@trb.org"}, {"email"=>"nick@trb.org"}]})
    model = op.model

    model.users.size.must_equal 2
    model.users[0].attributes.slice("id", "email").must_equal("id"=>solnic.id, "email"=>"solnic@trb.org") # existing user attached to thing.
    model.users[1].email.must_equal "nick@trb.org" # new user created.

    # authorship is not confirmed, yet.
    model.authorships.pluck(:confirmed).must_equal [0, 0]

    op.invocations[:default].invocations[0].must_equal [:on_add, :notify_author!, [op.contract.users[0], op.contract.users[1]]]


    # unconfirmed signup.
    Tyrant::Authenticatable.new(model.users[0]).confirmable?.must_equal false # TODO: entry points for users!
    # model.users[0].auth_meta_data.must_equal(nil) # existing user doesn't need unconfirmed signup.
    # model.users[1].auth_meta_data.must_equal({:confirmation_token=>"asdfasdfasfasfasdfasdf", :confirmation_created_at=>"assddsf"})
    Tyrant::Authenticatable.new(model.users[1]).confirmable?.must_equal true
  end

  # too many users
  it "users > 3" do
    emails = 4.times.collect { |i| {"email"=>"#{i}@trb.org"} }
    res, op = Thing::Create.run(thing: {name: "Rails", users: emails})

    res.must_equal false
    op.errors.to_s.must_equal "{:users=>[\"is too long (maximum is 3 characters)\"]}"
  end

  # author has more than 5 unconfirmed authorships.
  it do
    # Session::SignUp.(session: {email: "nick@trb.org"})
    User.create(email: "nick@trb.org") # this is "confirmed".

    5.times { |i| Thing::Create.(thing: {name: "Rails #{i}", users: [{"email"=>"nick@trb.org"}]}) }
    res, op = Thing::Create.run(thing: {name: "Rails", users: [{"email"=>"nick@trb.org"}]})

    res.must_equal false
    op.errors.to_s.must_equal "{:\"users.user\"=>[\"This user has too many unconfirmed authorships.\"]}"
  end

  # author is unconfirmed-needs-password and can only be added to one thing.
  it "zz" do
    Thing::Create.(thing: {name: "Rails", users: [{"email"=>"nick@trb.org"}]}) # nick@trb.org is unsignedup
    res, op = Thing::Create.run(thing: {name: "Trb", users: [{"email"=>"nick@trb.org"}]})
    res.must_equal false
  end


  describe "I'm the author!" do
    let (:user) { User::Create.(user: {email: "nick@trb.org"}).model }

    # anonymous
    it do
      thing = Thing::Create.(thing: {name: "Rails", users: [{"email"=>user.email}], is_author: "1"}, current_user: nil).model
      thing.users.must_equal [user]
    end

    # signed-in
    it do
      thing = Thing::Create.(thing: {name: "Rails", users: [{"email"=>user.email}], is_author: "1"}, current_user: current_user).model
      thing.users.must_equal [user, current_user]
    end

    it "doesn't add current_user when is_author: 0" do
      thing = Thing::Create.(thing: {name: "Rails", users: [{"email"=>user.email}], is_author: "0"}, current_user: current_user).model
      thing.users.must_equal [user]
    end

    it "doesn't add current_user when :is_author is absent" do
      thing = Thing::Create.(thing: {name: "Rails", users: [{"email"=>user.email}]}, current_user: current_user).model
      thing.users.must_equal [user]
    end

    # admin
    it do
      op    = Thing::Create.(thing: {name: "Rails", users: [{"email"=>user.email}], is_author: "1"}, current_user: admin)
      thing = op.model
      thing.users.must_equal [user, admin]
      op.must_be_instance_of Thing::Create::Admin
    end
  end
end