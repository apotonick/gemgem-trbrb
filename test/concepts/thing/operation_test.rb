# require 'test_helper'

# class ThingOperationTest < MiniTest::Spec
#   describe "Create" do
#     it "persists valid" do
#       thing = Thing::Create.(thing: {name: "Rails", description: "Kickass web dev"}).model

#       thing.persisted?.must_equal true
#       thing.name.must_equal "Rails"
#       thing.description.must_equal "Kickass web dev"
#     end

#     it "invalid" do
#       res, op = Thing::Create.run(thing: {name: ""})

#       res.must_equal false
#       op.errors.to_s.must_equal "{:name=>[\"can't be blank\"]}"
#       op.model.persisted?.must_equal false
#       op.invocations[:default].must_equal nil
#     end

#     it "invalid description" do
#       res, op = Thing::Create.run(thing: {name: "Rails", description: "hi"})

#       res.must_equal false
#       op.errors.to_s.must_equal "{:description=>[\"is too short (minimum is 4 characters)\"]}"
#     end

#     # users
#     it "invalid email" do
#       res, op = Thing::Create.run(thing: {name: "Rails", users: [{"email"=>"invalid format"}, {"email"=>"bla"}]})

#       res.must_equal false
#       op.errors.to_s.must_equal "{:\"users.email\"=>[\"is invalid\"]}"

#       # still 3 users
#       form = op.contract
#       form.prepopulate! # FIXME: hate this. move prepopulate! to Op#run.

#       form.users.size.must_equal 3 # always offer 3 user emails.
#       form.users[0].email.must_equal "invalid format"
#       form.users[1].email.must_equal "bla"
#       form.users[2].email.must_equal nil # this comes from prepopulate!
#     end

#     # all emails blank
#     it "all emails blank" do
#       res, op = Thing::Create.run(thing: {name: "Rails", users: [{"email"=>""}]})

#       res.must_equal true
#       op.model.users.must_equal []
#     end

#     it "valid, new and existing email" do
#       solnic = User.create(email: "solnic@trb.org") # TODO: replace with operation, once we got one.
#       User.count.must_equal 1

#       op = Thing::Create.(thing: {name: "Rails", users: [{"email"=>"solnic@trb.org"}, {"email"=>"nick@trb.org"}]})
#       model = op.model

#       model.users.size.must_equal 2
#       model.users[0].attributes.slice("id", "email").must_equal("id"=>solnic.id, "email"=>"solnic@trb.org") # existing user attached to thing.
#       model.users[1].email.must_equal "nick@trb.org" # new user created.

#       # authorship is not confirmed, yet.
#       model.authorships.pluck(:confirmed).must_equal [0, 0]
#       # callbacks invoked.
#       op.invocations[:default].invocations[0].must_equal [:on_add, :notify_author!, [op.contract.users[0], op.contract.users[1]]]

#       # unconfirmed signup.
#       Tyrant::Authenticatable.new(model.users[0]).confirmable?.must_equal false # TODO: entry points for users!
#       Tyrant::Authenticatable.new(model.users[1]).confirmable?.must_equal true
#     end

#     # too many users
#     it "users > 3" do
#       emails = 4.times.collect { |i| {"email"=>"#{i}@trb.org"} }
#       res, op = Thing::Create.run(thing: {name: "Rails", users: emails})

#       res.must_equal false
#       op.errors.to_s.must_equal "{:users=>[\"is too long (maximum is 3 characters)\"]}"
#     end

#     # author has more than 5 unconfirmed authorships.
#     it do
#       User.create(email: "nick@trb.org") # this is "confirmed".

#       5.times { |i| Thing::Create.(thing: {name: "Rails #{i}", users: [{"email"=>"nick@trb.org"}]}) }
#       res, op = Thing::Create.run(thing: {name: "Rails", users: [{"email"=>"nick@trb.org"}]})

#       res.must_equal false
#       op.errors.to_s.must_equal "{:\"users.user\"=>[\"This user has too many unconfirmed authorships.\"]}"
#     end

#     # author is sleeping and can only be added to one thing.
#     it do
#       Thing::Create.(thing: {name: "Rails", users: [{"email"=>"nick@trb.org"}]}) # nick@trb.org is unsignedup
#       res, op = Thing::Create.run(thing: {name: "Trb", users: [{"email"=>"nick@trb.org"}]})
#       res.must_equal false
#     end

#     describe "I'm the author!" do
#     let (:user) { User::Create.(user: {email: "nick@trb.org"}).model }

#     # anonymous
#     it do
#       thing = Thing::Create.(thing: {name: "Rails", users: [{"email"=>user.email}], is_author: "1"}, current_user: nil).model
#       thing.users.must_equal [user]
#     end

#     # signed-in
#     it do
#       thing = Thing::Create.(thing: {name: "Rails", users: [{"email"=>user.email}], is_author: "1"}, current_user: current_user).model
#       thing.users.must_equal [user, current_user]
#     end

#     it "doesn't add current_user when is_author: 0" do
#       thing = Thing::Create.(thing: {name: "Rails", users: [{"email"=>user.email}], is_author: "0"}, current_user: current_user).model
#       thing.users.must_equal [user]
#     end

#     it "doesn't add current_user when :is_author is absent" do
#       thing = Thing::Create.(thing: {name: "Rails", users: [{"email"=>user.email}]}, current_user: current_user).model
#       thing.users.must_equal [user]
#     end

#     # admin
#     it do
#       op    = Thing::Create.(thing: {name: "Rails", users: [{"email"=>user.email}], is_author: "1"}, current_user: admin)
#       thing = op.model
#       thing.users.must_equal [user, admin]
#       op.must_be_instance_of Thing::Create::Admin
#     end
#   end

#     describe "upload" do
#       # valid file upload.
#       it "valid upload" do
#         thing = Thing::Create.(thing: {name: "Rails",
#           file: File.open("test/images/cells.jpg")}).model

#         Paperdragon::Attachment.new(thing.image_meta_data).exists?.must_equal true
#       end

#       it "hack" do
#         thing = Thing::Create.(thing: {name: "Rails",
#           image_meta_data: {bla: 1}}).model
#         thing.image_meta_data.must_equal nil
#       end

#       # invalid file upload.
#       it "invalid upload" do
#         res, op = Thing::Create.run(thing: {name: "Rails",
#           file: File.open("test/images/hack.pdf")})

#         res.must_equal false
#         op.errors.to_s.must_equal "{:file=>[\"file has an extension that does not match its contents\", \"file should be one of image/jpeg, image/png\"]}"
#       end
#     end
#   end

#   describe "Update" do
#     let (:thing) { Thing::Create.(thing: {name: "Rails", description: "Kickass web dev", "users"=>[{"email"=>"solnic@trb.org"}]}).model }

#     it "rendering" do # DISCUSS: not sure if that will stay here, but i like the idea of presentation/logic in one place.
#       form = Thing::Update.present({id: thing.id}).contract
#       form.prepopulate! # this is a bit of an API breach.

#       form.users.size.must_equal 3 # always offer 3 user emails.
#       form.users[0].email.must_equal "solnic@trb.org"
#       form.users[0].id.must_equal thing.users[0].id
#       form.users[1].email.must_equal nil
#       form.users[2].email.must_equal nil
#     end

#     it "persists valid, ignores name" do
#       Thing::Update.(
#         id:     thing.id,
#         thing: {name: "Lotus", description: "MVC, well.."}).model

#       thing.reload
#       thing.name.must_equal "Rails"
#       thing.description.must_equal "MVC, well.."
#     end

#     it "valid, new and existing email" do
#       solnic = thing.users[0]
#       model  = Thing::Update.(id: thing.id, thing: {"users" => [{"id"=>solnic.id, "email"=>"solnicXXXX@trb.org"}, {"email"=>"nick@trb.org"}]}).model

#       model.users.size.must_equal 2
#       model.users[0].attributes.slice("id", "email").must_equal("id"=>solnic.id, "email"=>"solnic@trb.org") # existing user, nothing changed.
#       model.users[1].email.must_equal "nick@trb.org" # new user created.
#       model.users[1].persisted?.must_equal true
#     end

#     # hack: try to change emails.
#     it "doesn't allow changing existing email" do
#       op = Thing::Create.(thing: {name: "Rails  ", users: [{"email"=>"nick@trb.org"}]})

#       op = Thing::Update.(id: op.model.id, thing: {users: [{"email"=>"wrong@nerd.com"}]})
#       op.model.users[0].email.must_equal "nick@trb.org"
#     end

#     # all emails blank
#     it "all emails blank" do
#       op = Thing::Create.(thing: {name: "Rails  ", users: []})

#       res, op = Thing::Update.run(id: op.model.id, thing: {name: "Rails", users: [{"email"=>""},{"email"=>""}]})

#       res.must_equal true
#       op.model.users.must_equal []
#     end

#     # remove
#     it "allows removing" do
#       op  = Thing::Create.(thing: {name: "Rails  ", users: [{"email"=>"joe@trb.org"}]})
#       joe = op.model.users[0]

#       res, op = Thing::Update.run(id: op.model.id, thing: {name: "Rails", users: [{"id"=>joe.id.to_s, "remove"=>"1"}]})

#       res.must_equal true
#       op.model.users.must_equal []
#       joe.persisted?.must_equal true
#     end
#   end
# end

# class ThingSignedInOperationTest < MiniTest::Spec
#   describe "Create::SignedIn" do
#     let (:current_user) { User.create(email: "solnic@trb.org") } # TODO: replace with operation, once we got one.

#     # valid, no flag set.
#     it do
#       model  = Thing::Create.(
#         current_user: current_user,
#         thing:        {"name"=>"Rails", "users" => [{"email"=>"nick@trb.org"}], "is_author"=> "0"}
#       ).model

#       model.users.map { |u| u.email }.must_equal(["nick@trb.org"])
#     end

#     # valid, flag set.
#     it do
#       model  = Thing::Create.(
#         current_user: current_user,
#         thing:        {"name"=>"Rails", "users" => [{"email"=>"nick@trb.org"}], "is_author"=>"1"}
#       ).model

#       model.users.map { |u| u.email }.must_equal(["nick@trb.org", "solnic@trb.org"])
#     end
#   end
# end