module Navigation
  # DISCUSS: Context object? or from Tyrant?
  class Cell < ::Cell::Concept
    property :current_user
    property :real_user
    property :signed_in?

    def show
      render
    end

  private
    def links
      render
    end

    def welcome_signed_in
      link_to("#{impersonate_icon} Hi, #{current_user.email}".html_safe, user_path(current_user))
    end

    def impersonate_icon
      return unless real_user
      "<i data-tooltip class=\"fi-sheriff-badge\" title=\"You really are: #{real_user.email}\"></i>"
    end
  end
end