module Thing::Contract
  class Update < Create
    property :name, writeable: false

    # DISCUSS: should inherit: true be default?
    collection :users, inherit: true, populator: :user! do
      property :email, skip_if: :skip_email?

      def skip_email?(fragment, options)
        model.persisted?
      end
    end

  private
    def user!(fragment:, index:, **)
      # don't process if it's getting removed!
      if fragment["remove"] == "1"
        deserialized_user = users.find { |u| u.id.to_s == fragment["id"] }
        users.delete(deserialized_user)
        return Representable::Pipeline::Stop
      end

      # skip if already existing
      return Representable::Pipeline::Stop if users[index]

      users.insert(index, User.new)
    end
  end
end