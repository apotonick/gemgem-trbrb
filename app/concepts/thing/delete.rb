class Thing::Delete < Trailblazer::Operation
  include Model
  model Thing, :find
  policy Thing::Policy, :delete?

  def process(params)
    model.destroy
    delete_images!
    expire_cache!
  end

private
  def delete_images!
    Thing::ImageProcessor.new(model.image_meta_data).image! { |v| v.delete! }
  end

  include Gemgem::ExpireCache
end