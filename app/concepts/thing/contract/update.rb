module Thing::Contract
  class Update < Create
    property :name, writeable: false

    # DISCUSS: should inherit: true be default?
    collection :users, inherit: true, populator: :user! do
      property :email, skip_if: :skip_email?

      def skip_email?(options)
        model.persisted?
      end
    end

  private
    def user!(fragment:, index:, **)
      # don't process if it's getting removed!
      if fragment["remove"] == "1"
        deserialized_user = users.find_by(id: fragment["id"])
        users.delete(deserialized_user)
        return skip!
      end

      # skip if already existing
      return skip! if users[index]

      users.insert(index, User.new)
    end
  end
end
