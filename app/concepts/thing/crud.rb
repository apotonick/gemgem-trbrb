class Thing < ActiveRecord::Base

  class Create < Trailblazer::Operation
    include CRUD
    model Thing, :create

    contract do
      model Thing
      property :name, validates: {presence: true}
    end

    def process(params)
      validate(params[:thing]) do |f|
        f.save
      end
    end
  end

  class Update < Create
    action :update
  end
end