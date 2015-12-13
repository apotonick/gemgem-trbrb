module Gemgem
  module ExpireCache # DISCUSS: could also be class.
    def expire_cache!(*)
      CacheVersion.for("thing/cell/grid").expire! # of course, this is only temporary as it
      # 1. binds Op to view.
      # 2. expires cache even if thing is not part of that screen.
    end
  end
end