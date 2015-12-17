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


end
