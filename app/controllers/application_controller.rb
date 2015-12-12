class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def tyrant
    Tyrant::Session.new(request.env['warden'])
  end
  helper_method :tyrant


  # def process_params!(params)
  #   params.merge!(current_user: tyrant.current_user)
  # end

  require_dependency "session/impersonate"
  before_filter { Session::Impersonate.(params.merge!(tyrant: tyrant)) } # TODO: allow Op.(params, session)

  rescue_from Trailblazer::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    flash[:message] = "Not authorized, my friend."
    redirect_to root_path
  end
end
