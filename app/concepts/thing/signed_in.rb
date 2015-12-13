module Thing::SignedIn
  include Trailblazer::Operation::Module

  contract do
    property :is_author, virtual: true, default: "0"

    # def is_author_
    #   puts "@@@@@ :: #{super.inspect}"
    #   super || "0"
    #   # puts "@@@@@ #{super.inspect}"
    #   # return super.() if super.is_a?(Uber::Options::Value)
    #   # super
    # end
  end

  callback(:upload) do
    on_change :add_current_user_as_author!, property: :is_author

    def add_current_user_as_author!(thing, params:, **)
      thing.users << params[:current_user]
    end
  end
end