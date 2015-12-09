class Thing < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include Model
    model Thing, :create

    contract do
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