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
    classes = ["box", "large-3", "columns"]
    classes << "end" if options[:last] == model
    classes
  end


  # The public helper that collects latest things and renders the grid.
  class Grid < Cell::Concept
    def show
      things = Thing.latest
      concept("thing/cell", collection: things, last: things.last)
    end
  end
end