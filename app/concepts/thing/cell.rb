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





end