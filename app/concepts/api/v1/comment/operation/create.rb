module API::V1
  module Comment
    class Create < ::Comment::Create
      include Trailblazer::Operation::Representer, Responder

      include Deserializer::Hash
      representer Representer::Show
    end
  end
end