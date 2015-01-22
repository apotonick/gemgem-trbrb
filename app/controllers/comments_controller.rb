class CommentsController < ApplicationController
  def new
    @thing = Thing.find(params[:thing_id]) # UI-specific logic!

    form Comment::Create
  end

  def create
    run Comment::Create do |op|
      return redirect_to thing_path(op.thing)
    end

    render :new
  end
end