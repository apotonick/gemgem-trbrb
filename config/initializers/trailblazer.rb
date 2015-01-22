require 'reform/form/json'
require 'reform/form/coercion'

require "roar/json"
require 'roar/json/hal'

require 'trailblazer/autoloading'

# TODO: this was handled in roar-rails. we don't need roar-rails in Trailblazer (yay!), so provide this via Trb.
# initializer "roar.set_configs" do |app|
  ::Roar::Representer.module_eval do
    include Rails.application.routes.url_helpers
    # include Rails.app.routes.mounted_helpers

    def default_url_options
      {}
    end
  end
# end

# this is too late, apparently. the railtie is not considered anymore.
# require 'trailblazer/rails/railtie'


# I extend the CRUD module here to make it also include CRUD::ActiveModel globally. This is my choice as the
# application architect. Don't do it if you don't use ActiveModel form builders/models.
Trailblazer::Operation::CRUD.module_eval do
  module Included
    def included(base)
      super # the original CRUD::included method.
      base.send :include, Trailblazer::Operation::CRUD::ActiveModel
    end
  end
  extend Included # override CRUD::included.
end