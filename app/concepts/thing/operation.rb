class Thing < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include Model
    model Thing, :create

    contract Contract::Create

    include Dispatch # TODO: in initializer.
    callback :default, Callback::Default
    callback :before_save, Callback::BeforeSave

    def process(params)
      validate(params[:thing]) do |f|
        dispatch!(:before_save)
        # upload_image!(f) if f.changed?(:file)
        f.save

        dispatch!
      end
    end

  private
    def reset_authorships!
      model.authorships.each { |authorship| authorship.update_attribute(:confirmed, 0) }
    end
  end

  class Update < Create
    action :update

    contract Contract::Update
  end
end