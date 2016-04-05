module Thing::SignedIn
  include Trailblazer::Operation::Module

  contract do
    property :is_author, virtual: true, default: "0"
  end

  callback(:before_save) do
    on_change :add_current_user_as_author!, property: :is_author

    def add_current_user_as_author!(thing, params:, **)
      thing.users << params[:current_user]
    end
  end
end
