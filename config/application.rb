require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsFoundation
  class Application < Rails::Application
    # For Foundation 5
    config.assets.precompile += %w( vendor/modernizr )

    config.reform.validations = :active_model
  end
end

# railties have to be loaded here.
require 'trailblazer/rails/railtie'
