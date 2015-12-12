class Comment < ActiveRecord::Base
  class Create < Trailblazer::Operation
    builds -> (params) do
      SignedIn if params[:current_user]
    end

    include Model
    model Comment, :create

    contract do
      include Reform::Form::ModelReflections

      def self.weights
        {"0" => "Nice!", "1" => "Rubbish!"}
      end

      def weights
        [self.class.weights.to_a, :first, :last]
      end


      property :body
      property :weight, prepopulator: lambda { |*| self.weight= "0" }
      property :thing

      validates :body, length: { in: 6..160 }
      validates :weight, inclusion: { in: weights.keys }
      validates :thing, :user, presence: true

      property :user,
          # prepopulator:      lambda { |options| self.user = User.new },
          populate_if_empty: lambda { |*| User.new } do
        property :email
        validates :email, presence: true, email: true
      end
    end

    callback do
      on_change :sign_up_sleeping!, property: :user
     end

    def process(params)
      validate(params[:comment]) do |f|
        dispatch!

        f.save # save comment and user.
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


    require_dependency "session/operations"
    def sign_up_sleeping!(comment)
      Session::SignUp::UnconfirmedNoPassword.(user: comment.user.model)
    end


    class SignedIn < Create
      contract do
        property :user, deserializer: {writeable: false} do
        end # TODO: allow to remove.
        validates :user, presence: :true
      end

      def sign_up_sleeping!(comment)
        # TODO: allow to skip.
      end

      def process(params)
        contract.user = params[:current_user]

        # params[:comment].delete(:user_attributes)  # FIXME!
        # params[:comment][:user] = params[:current_user]
        super
      end

      # def setup_params!(params)
      #     # FIXME: this is also called in Op#form context. find a better way for "params handling".
      #   params[:comment][:user] = params[:current_user] if params[:comment]# TODO: how do we handle missing [:comment]?
      # end
    end
  end
end