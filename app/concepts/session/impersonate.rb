module Session
  class Setup < Trailblazer::Operation
    def process(params)
      params[:current_user] = params[:tyrant].current_user
      # DISCUSS: we could also only pass the tyrant object into Ops without maintaining that :current_user key?
    end
  end

  class Impersonate < Trailblazer::Operation
    include Policy
    policy Thing::Policy, :admin?
    # DISCUSS: from here on, i'm assuming we will introduce a Context object or something
    # that keeps all that data (logged in, impersonate, params, session, etc.) but to
    # experiment, i use params, Scharrels. ;)
    def setup!(params)
      Setup.(params)
      return unless params[:as]
      super # runs policy.
      impersonate!(params)
    end

    def process(params)
    end

  private
    def impersonate!(params)
      simulated = User.find_by!(email: params[:as])
      params[:current_user] = simulated
      params[:real_user]    = params[:tyrant].current_user
    end
  end
end