module API::V1
  module Thing
    class Update < ::Thing::Update
      self.builder_class = ::Thing::Create.builder_class

      class Admin < ::Thing::Update::Admin
        include Trailblazer::Operation::Representer
        representer Create.representer
      end
    end
  end
end
