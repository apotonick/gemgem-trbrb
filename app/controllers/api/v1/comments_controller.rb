module API::V1
  class CommentsController < ApplicationController
    respond_to :json

    def show
      respond Comment::Show
    end

    def create
      respond Comment::Create,
        params: params.merge(id: params[:thing_id]), # FIXME: rename Comment::Create(id:) to :thing_id.
        namespace: [:api, :v1]
    end
  end
end