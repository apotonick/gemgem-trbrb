class Thing::Cell::Form < ::Cell::Concept
  inherit_views Thing::Cell

  include ActionView::RecordIdentifier
  include SimpleForm::ActionViewExtensions::FormHelper

  def show
    render :form
  end

private
  property :contract

  def css_class
    return "admin" if admin?
    ""
  end

  def has_author_field?
    contract.options_for(:is_author)
  end

  # this will be ::property :signed_in?, boolean: true
  def admin?
    model.policy.admin?
  end
end