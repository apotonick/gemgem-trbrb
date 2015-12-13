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

      class Index < Roar::Decorator
        feature Roar::JSON::HAL

        with_comments = Class.new(Create) do
          collection :comments, decorator: Comment::Representer::Show, embedded: true
        end

        collection :to_a, as: :things, embedded: true, decorator: with_comments

        link(:self) { |params:, **|
          options = {}
          options[:sort] = params[:sort] if params[:sort]

          api_v1_things_path(options)
        }
      end

      class Show < Create
        collection :comments, embedded: true do
          property :body
        end
      end
    end
  end
end
