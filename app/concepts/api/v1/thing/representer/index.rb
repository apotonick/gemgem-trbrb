module API::V1
  module Thing
    module Representer
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
    end
  end
end
