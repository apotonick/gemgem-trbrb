module Thing::Cell
  # The public helper that collects latest things and renders the grid.
  class Grid < Trailblazer::Cell
    include Cell::Caching::Notifications

    cache :show do
      CacheVersion.for("thing/cell/grid")
    end

    def show
      things = Thing.latest
      concept("thing/cell/teaser", collection: things, last: things.last)
    end
  end
end
