class Thing::Cell < Cell::Concept
  property :name
  property :description
  property :created_at

  include Gemgem::Cell::CreatedAt

  def show
    render
  end

private
  def name_link
    link_to name, thing_path(model)
  end

  def classes
    classes = ["box", "large-3", "columns"]
    classes << "end" if options[:last] == model
    classes
  end


  # The public helper that collects latest things and renders the grid.
  class Grid < Cell::Concept
    include Cell::Caching::Notifications

    cache :show do
      CacheVersion.for("thing/cell/grid")
    end

    def show
      things = Thing.latest
      concept("thing/cell", collection: things, last: things.last)
    end
  end

  class Decorator < Cell::Concept
    extend Paperdragon::Model::Reader
    processable_reader :image
    property :image_meta_data

    def thumb
      image_tag image[:thumb].url, class: :th if image.exists?
    end
  end
end