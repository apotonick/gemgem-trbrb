class Comment::Cell < Cell::Concept
  property :created_at
  property :body
  property :user

  include Cell::GridCell
  self.classes = ["comment", "large-4", "columns"]

  include Cell::CreatedAt

  def show
    render
  end

private
  def nice?
    model.weight == 0
  end


  class Grid < Cell::Concept
    inherit_views Comment::Cell

    include Kaminari::Cells
    include ActionView::Helpers::JavaScriptHelper

    def show
      # paginate(comments)
      # concept( "comment/cell", paginated_options) + paginate(paginated_options[:collection])
      # concept( "comment/cell", paginated_options) + link_to_next_page(paginated_options[:collection], 'Next Page') #paginate(paginated_options[:collection])
      render :grid
    end

    def append
      %{ $("#next").replaceWith("#{j(show)}") }
    end

  private
    def page
      options[:page] or 1
    end

    def comments
      # talk about why we don't need an Operation, yet, to collect comments here.
      @comments ||= model.comments.page(page).per(3)
    end
  end
end