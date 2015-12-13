require_dependency "thing/policy" # TODO: do with trailblazer-loader

class Thing < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include Resolver
    policy Thing::Policy, :create?

    builds -> (model, policy, params) do
      return self::Admin    if policy.admin?
      return self::SignedIn if policy.signed_in?
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

    class Admin < SignedIn
    end
  end

  class Update < Create
    self.builder_class = Create.builder_class
    policy Thing::Policy, :update?
    action :update

    contract Contract::Update

    class SignedIn < self
      include Thing::SignedIn

      contract do
        property :name, writeable: false
      end
    end

    class Admin < SignedIn
      include Thing::SignedIn

      contract do
        property :name
      end
    end
  end

  class Show < Trailblazer::Operation
    include Model
    model Thing, :find

    include Trailblazer::Operation::Policy
    policy Thing::Policy, :show?
  end

  ImageProcessor = Struct.new(:image_meta_data) do
    extend Paperdragon::Model::Writer
    processable_writer :image
  end
end

require_dependency "thing/delete" # TODO: do with trailblazer-loader