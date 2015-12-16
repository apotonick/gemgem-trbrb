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

end