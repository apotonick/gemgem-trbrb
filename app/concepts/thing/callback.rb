module Thing::Callback
  class Upload < Disposable::Callback::Group
    on_change :upload_image!, property: :file

    collection :users do
      on_add :sign_up_sleeping!
    end

    def upload_image!(thing, operation:, **)
      operation.contract.image!(operation.contract.file) do |v|
        v.process!(:original)
        v.process!(:thumb)   { |job| job.thumb!("120x120#") }
      end
    end

    def sign_up_sleeping!(user, *)
      return if user.persisted? # only new
      Session::SignUp::UnconfirmedNoPassword.(user: user.model)
    end
  end

  class Default < Disposable::Callback::Group
    collection :users do
      on_add :notify_author!
      on_add :reset_authorship!
      # on_delete :notify_deleted_author! # in Update!
    end
    # on_change :rehash_email!, property: :email
    on_change :expire_cache! # on_change
    # on_update :expire_cache!

    def notify_author!(user, *)
      # NewUserMailer.welcome_email(user)
    end

    def reset_authorship!(user, operation:, **)
      user.model.authorships.find_by(thing_id: operation.model.id).update_attribute(:confirmed, 0)
    end

    def expire_cache!(thing, *)
      CacheVersion.for("thing/cell/grid").expire! # of course, this is only temporary as it
      # 1. binds Op to view.
      # 2. expires cache even if thing is not part of that screen.
    end
  end
end