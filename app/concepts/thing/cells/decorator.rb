class Thing::Cell < Cell::Concept
  class Decorator < Cell::Concept
    extend Paperdragon::Model::Reader
    processable_reader :image
    property :image_meta_data

    def thumb
      image_tag image[:thumb].url, class: :th if image.exists?
    end
  end
end