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
    include Kaminari::Cells

    def show

      concept( "comment/cell", paginated_options) + paginate(paginated_options[:collection])
    end

  private
    def page
      options[:page] or 1
    end

    def paginated_options
      comments = model.comments.page(page).per(3)

      {collection: comments, last: comments.last}
    end
  end
end