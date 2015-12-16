class Thing::Cell < Cell::Concept

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
end