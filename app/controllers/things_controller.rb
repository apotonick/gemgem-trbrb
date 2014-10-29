class ThingsController < ApplicationController
  def new
    present Thing::Create
  end

  def create
    run Thing::Create do |op|
      redirect_to op.model
    end.else do |op|
      render action: :new
    end
  end
end