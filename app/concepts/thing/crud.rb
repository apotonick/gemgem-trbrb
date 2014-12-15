class Thing < ActiveRecord::Base

  class Create < Trailblazer::Operation
    include CRUD
    model Thing, :create

    contract do
      model Thing # this will be infered in the next trb release.

      property :name
      property :description

      validates :name, presence: true
      validates :description, length: {in: 4..160}, allow_blank: true
    end

    def process(params)
      validate(params[:thing]) do |f|
        f.save
      end
    end
  end

  class Update < Create
    action :update

    contract do
      property :name, writeable: false
    end
  end
end