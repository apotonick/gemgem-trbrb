module API::V1
  module Thing
    class Create < ::Thing::Create
      include Trailblazer::Operation::Representer, Responder

      representer Representer::Create
    end

    class Show < ::Thing::Show
      include Trailblazer::Operation::Representer

      representer Representer::Show

      def process(*)

      end
    end
  end
end
