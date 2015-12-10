module Thing::Contract
  class Create < Reform::Form
    property :name
    property :description

    validates :name, presence: true
    validates :description, length: {in: 4..160}, allow_blank: true

    collection :users,
        prepopulator:      :prepopulate_users!,
        populate_if_empty: :populate_users!,
        skip_if:           :all_blank do

      property :email
      property :remove, virtual: true
      validates :email, presence: true, email: true
      validate :authorship_limit_reached?

      def readonly? # per form.
        model.persisted?
      end
      alias_method :removeable?, :readonly?

    private
      def authorship_limit_reached?
        return if model.authorships.find_all { |au| au.confirmed == 0 }.size < 5
        errors.add("user", "This user has too many unconfirmed authorships.")
      end
    end
    validates :users, length: {maximum: 3}

  private
    def prepopulate_users!(options)
      (3 - users.size).times { users << User.new }
    end

    def populate_users!(fragment:, **)
      User.find_by_email(fragment["email"]) or User.new
    end
  end

  class Update < Create
    property :name, writeable: false

    # DISCUSS: should inherit: true be default?
    collection :users, inherit: true, skip_if: :skip_user? do
      property :email, skip_if: :skip_email?

      def skip_email?(fragment, options)
        model.persisted?
      end
    end

  private
    def skip_user?(fragment, options)
      # don't process if it's getting removed!
      return true if fragment["remove"] == "1" and users.delete(users.find { |u| u.id.to_s == fragment["id"] })

      # skip when user is an existing one.
      # return true if users[index] and users[index].model.persisted?

      # replicate skip_if: :all_blank logic.
      return true if fragment["email"].blank?
    end
  end
end