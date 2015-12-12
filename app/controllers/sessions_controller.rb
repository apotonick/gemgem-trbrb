class SessionsController < ApplicationController
  def sign_up_form
    form Session::SignUp
  end

  def sign_up
    run Session::SignUp do |op|
      flash[:notice] = "Please log in now!"
      return redirect_to sessions_sign_in_form_path
    end

    render action: :sign_up_form
  end

  # before_filter should be used when op not involved at all.
  before_filter( only: [:sign_in_form, :sign_up_form]) { redirect_to root_path if tyrant.signed_in? } # TODO: provide that by Tyrant::Controller.
  def sign_in_form
    form Session::SignIn
  end

  def sign_in
    run Session::SignIn do |op|
      tyrant.sign_in!(op.model)
      return redirect_to root_path
    end

    render action: :sign_in_form
  end

  # TODO: test me.
  def sign_out
    run Session::SignOut do
      tyrant.sign_out!
      redirect_to root_path
    end
  end


  # TODO: should be in one Op.
  # we could also provide 2 different steps: via before filter OR validate token in form?
  before_filter only: [:wake_up_form] { Session::IsConfirmable.reject(params) { redirect_to( root_path) } }

  def wake_up_form
    form Session::ChangePassword # TODO: require_original: true
  end

  def wake_up
    run Session::ChangePassword do
      flash[:notice] = "Password changed."
       redirect_to sessions_sign_in_form_path # TODO: user profile.
       return
    end # TODO: require_original: true

    render :wake_up_form
  end

  def operation_model_name # FIXME.
   "FIXME"
  end
end