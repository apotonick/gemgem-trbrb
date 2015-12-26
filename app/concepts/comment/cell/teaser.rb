module Comment::Cell
  class Teaser < Trailblazer::Cell
    property :created_at
    property :body
    property :user

    include Gemgem::Cell::GridCell
    self.classes = ["comment", "large-4", "columns"]

    include Gemgem::Cell::CreatedAt

  private
    def nice?
      model.weight == 0
    end
  end
end
