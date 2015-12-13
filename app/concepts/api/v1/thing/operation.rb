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

    class Update < ::Thing::Update
      self.builder_class = ::Thing::Create.builder_class

      class Admin < ::Thing::Update::Admin
        include Trailblazer::Operation::Representer
        representer Create.representer
      end
    end

    class Index < Trailblazer::Operation
      def model!(params)
        return ::Thing.oldest if params[:sort] == "oldest"
        ::Thing.latest
      end

      def process(*)

      end

      include Trailblazer::Operation::Representer
      representer Representer::Index

      def to_json(*)
        options = { user_options: {} }
        options[:user_options][:params] = @params
        options[:to_a] = {}

        if @params[:include]
          scalars = self.class.representer.definitions.get(:to_a).representer_module.
            definitions.values.reject { |dfn| dfn.typed? }.map { |dfn| dfn[:name].to_sym }

          options[:to_a][:include] = [*scalars, :links, @params[:include].to_sym]
        end

        super(options)
      end
    end
  end
end
