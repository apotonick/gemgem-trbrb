class Comment < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include CRUD
    model Comment

    contract do
      include Reform::Form::ModelReflections
      model :comment

      property :body
      property :weight
      property :thing #, virtual: true

      property :user, populate_if_empty: User do # we could create the User in the Operation#process?
        property :email

        validates :email, presence: true
        # validates :email, email: true
        #validates_uniqueness_of :email # this assures the new user is new and not an existing one.

        # this should definitely NOT sit in the model.
        # validate :confirmed_or_new_and_unique?

        def confirmed_or_new_and_unique?
          existing = User.find_by_email(email)
          return if existing.nil?
          return if existing and existing.password_digest
          errors.add(:email, "User needs to be confirmed first.")
        end
      end
      validates :user, presence: true

      validates :body, length: { in: 6..160 }
      validates :thing, presence: true
    end


    def process(params) # or (params, env)
      model.thing = Thing.find_by_id(params[:id])

      validate(params[:comment]) do |f|
        f.save # save rating and user.
      end
    end
  end
end
