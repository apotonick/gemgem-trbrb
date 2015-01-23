class Comment < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include CRUD
    model Comment, :create

    contract do
      include Reform::Form::ModelReflections
      # include Reform::Form::Coercion
      reform_2_0!

      def self.weights
        {"0" => "Nice!", "1" => "Rubbish!"}
      end

      def weights
        [self.class.weights.to_a, :first, :last]
      end


      # property :endorsement, virtual: true #, type: Virtus::Attribute::Boolean

      property :body
      property :weight
      property :thing

      validates :body, length: { in: 6..160 }
      validates :weight, inclusion: { in: weights.keys }
      validates :thing, :user, presence: true

      property :user do
        property :email
        validates :email, presence: true, email: true
      end
    end

    def process(params)
      validate(params[:comment]) do |f|
        f.save # save comment and user.

        # Endorsement.create(user: f.model.user, thing: f.model.thing) if f.endorsement == "1"
      end
    end

    def thing
      model.thing
    end

  private
    def setup_model!(params)
      model.thing = Thing.find_by_id(params[:thing_id])
      model.build_user
    end
  end
end
