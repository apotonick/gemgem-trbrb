module API::V1
  module Thing
    module Representer
      class Create < Roar::Decorator
        feature Roar::JSON::HAL

        property   :name
        collection :users, as: :authors, embedded: true, render_empty: false, populator: Reform::Form::Populator::External.new do
          property :email

          link(:self) { api_v1_user_path(represented.id) }
        end

        link(:self) { api_v1_thing_path(represented) }
      end
    end
  end
end
