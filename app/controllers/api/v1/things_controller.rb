module API::V1
  class ThingsController < ApplicationController
    respond_to :json

    def index
      respond Thing::Index#, is_document: false
    end

    def show
      respond Thing::Show
    end

    def create
      # render json: op.to_json, location: "/op", status: :created
      respond Thing::Create, namespace: [:api, :v1], is_document: true #, location: "/op/"
    end

    def update
      if request.authorization
        email, password = ActionController::HttpAuthentication::Basic.user_name_and_password(request)

        Session::SignIn.run(session: { email: email, password: password }) do |op|
          # look how we do _not_ use any global variables for authentication!!!!!!! *win*
          params[:current_user] = op.model
        end
      end

      respond Thing::Update, namespace: [:api, :v1], is_document: true
    end
  end
end
