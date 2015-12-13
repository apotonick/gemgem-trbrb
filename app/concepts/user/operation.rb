class User < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include Model
    model User, :create

    def process(params)
      @model = User.create(params[:user])
    end
  end
end