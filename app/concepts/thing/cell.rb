class Thing::Cell < Cell::Concept
  property :name
  property :created_at

  include ActionView::Helpers::DateHelper
  include Rails::Timeago::Helper

  def show
    render
  end

private
  def name_link
    link_to name, thing_path(model)
  end

  def created_at
    timeago_tag(super)
  end

  def classes
    classes = ["large-3"]
    classes << "end" if options[:last] == model
    classes
  end
end
