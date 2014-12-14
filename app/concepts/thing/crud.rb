class Thing < ActiveRecord::Base

  class Create < Trailblazer::Operation
    include CRUD
    model Thing, :create

    contract do
      model Thing

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
    include Responder
    include Representer

    builds do |params|
      JSON if params[:format] == "json"
    end

    class JSON < self
      contract do
        include Reform::Form::JSON
      end

      representer do
        include Roar::JSON::HAL
        link(:self) { thing_path(represented) }
      end
    end
  end
end