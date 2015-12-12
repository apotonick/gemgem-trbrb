module Gemgem
  # Permission computers specific to your application (although most of this is pretty generic).
  module Policy # DISCUSS: could also be class.
    alias_method :call, :send # FIXME: used in @op.policy.(:show?)

    # app-specific:
    def admin?
      admin_for?(user) # from Gemgem::Policy.
    end

    def signed_in?
      user.present?
    end

  private
    attr_reader :model, :user

    def initialize(user, model) # DISCUSS: what about params?
      @user, @model, @params = user, model, nil
    end

    def admin_for?(user)
      return false unless user
      user.email == "admin@trb.org"
    end
  end
end