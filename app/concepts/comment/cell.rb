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
    def show
      concept "comment/cell", collection: model.comments, last: model.comments.last
    end
  end
end