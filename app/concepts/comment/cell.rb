class Comment::Cell < Cell::Concept
  property :created_at
  property :body

  include Cell::GridCell
  self.classes = ["comment", "large-4", "columns"]

  include Cell::CreatedAt

  def show
    render
  end


  class Grid < Cell::Concept
    inherit_views Comment::Cell

    include Kaminari::Cells
    include ActionView::Helpers::JavaScriptHelper

    def show
      # concept( "comment/cell", paginated_options) + paginate(paginated_options[:collection])
      # concept( "comment/cell", paginated_options) + link_to_next_page(paginated_options[:collection], 'Next Page') #paginate(paginated_options[:collection])
      render :grid
    end

    def append
      <<JS
        $("#next").replaceWith("#{j(show)}")
JS
    end

  private
    def page
      options[:page] or 1
    end

    def paginated_options
      # talk about why we don't need an Operation, yet, to collect comments here.
      comments = model.comments.page(page).per(3)

      {collection: comments, last: comments.last}
    end
  end
end