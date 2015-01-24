class Comment::Cell < Cell::Concept
  property :created_at
  property :body

  include Cell::GridCell
  self.classes = ["comment", "large-4", "columns"]

  include Cell::CreatedAt

  def show
    render
  end
end