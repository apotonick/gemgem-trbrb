class Comment < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include CRUD
    model Comment, :create

    contract do
      include Reform::Form::ModelReflections

      property :body
      property :weight
      property :thing #, virtual: true

      validates :body, length: { in: 6..160 }
      validates :weight, inclusion: { in: ["0", "1"] }
      validates :thing, presence: true


      property :user, populate_if_empty: User do
        property :email
        validates :email, presence: true, email: true
      end

      validates :user, presence: true

      def user
        User.new
      end
    end

    def process(params) # or (params, env)
      validate(params[:comment]) do |f|
        f.save # save rating and user.
      end
    end

  private
    def setup_model!(params)
      model.thing = Thing.find_by_id(params[:id])
      # model.build_user
    end
  end
end
