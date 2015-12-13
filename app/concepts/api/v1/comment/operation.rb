module API::V1
  module Comment
    class Show < Trailblazer::Operation
      include Model
      model ::Comment, :find

      include Trailblazer::Operation::Representer
      representer Representer::Show

      def process(*)
      end
    end

    class Create < ::Comment::Create
      include Trailblazer::Operation::Representer, Responder

      include Deserializer::Hash
      representer Representer::Show
    end
  end
end