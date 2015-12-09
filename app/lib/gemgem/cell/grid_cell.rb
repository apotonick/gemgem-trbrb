module Gemgem::Cell
  # adds #classes helper that will add a .last class when model and :last option match.
  # Requires you to set class attribute +classes+.
  #
  # class Thing::Cell < Cell::Concept
  #   include Cell::GridCell
  #   self.classes = ["columns", "large-3"]
  module GridCell
    def self.included(base)
      # define a class attribute.
      base.inheritable_attr :classes
    end

    def classes
      classes = self.class.classes.clone
      classes << "end" if options[:last] == model
      classes
    end

    # Create a container div with specified classes. Adds .end when passed in.
    def container(&block)
      content_tag(:div, class: classes, &block)
     end
  end
end