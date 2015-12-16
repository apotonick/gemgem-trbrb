require_dependency "thing/policy" # TODO: do with trailblazer-loader

class Thing < ActiveRecord::Base


  class Update < Create
    self.builder_class = Create.builder_class
    policy Thing::Policy, :update?
    action :update

    contract Contract::Update

    class SignedIn < self
      include Thing::SignedIn

      contract do
        property :name, writeable: false
      end
    end

    class Admin < SignedIn
      include Thing::SignedIn

      contract do
        property :name
      end
    end
  end


end
