class Comment::Cell < Cell::Concept
  include Cell::GridCell
  self.classes = ["comment", "large-4", "columns"]

  include ActionView::Helpers::DateHelper
  include Rails::Timeago::Helper

  property :created_at
  property :body

  def show
    render
  end

private
  def created_at
    timeago_tag(super)
  end
end