module API::V1
  module Thing
    module Representer
      class Show < Create
        collection :comments, embedded: true do
          property :body
        end
      end
    end
  end
end
