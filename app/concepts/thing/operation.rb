class Thing < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include Model
    model Thing, :create

    contract Contract::Create

    include Dispatch # TODO: in initializer.
    callback :default, Callback::Default
    callback :upload, Callback::Upload

    def process(params)
      validate(params[:thing]) do |f|
        dispatch!(:upload, context: nil, operation: self)
        # upload_image!(f) if f.changed?(:file)
        f.save

        dispatch!(:default, context: nil, operation: self)
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