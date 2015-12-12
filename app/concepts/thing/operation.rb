class Thing < ActiveRecord::Base
  class Create < Trailblazer::Operation
    builds do |params|
      SignedIn if params[:current_user]
    end

    include Model
    model Thing, :create

    contract Contract::Create

    include Dispatch # TODO: in initializer.
    callback :default, Callback::Default
    callback :upload, Callback::Upload

    def process(params)
      validate(params[:thing]) do |f|
        dispatch!(:upload)
        # upload_image!(f) if f.changed?(:file)
        f.save

        dispatch!
      end
    end

  private
    def reset_authorships!
      model.authorships.each { |authorship| authorship.update_attribute(:confirmed, 0) }
    end

    class SignedIn < self
      include Thing::SignedIn
    end
  end

  class Update < Create
    self.builder_class = Create.builder_class

    action :update

    contract Contract::Update

    class SignedIn < self
      include Thing::SignedIn
    end
  end
end