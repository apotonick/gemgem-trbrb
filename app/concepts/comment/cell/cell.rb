class Comment::Cell < Cell::Concept
  property :created_at
  property :body
  property :user

  include Gemgem::Cell::GridCell
  self.classes = ["comment", "large-4", "columns"]

  include Gemgem::Cell::CreatedAt

  def show
    render
  end

private
  def nice?
    model.weight == 0
  end
end
