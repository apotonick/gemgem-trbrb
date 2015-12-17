class Thing < ActiveRecord::Base


  class Show < Trailblazer::Operation
    include Model
    model Thing, :find

    include Trailblazer::Operation::Policy
    policy Thing::Policy, :show?
  end

  ImageProcessor = Struct.new(:image_meta_data) do
    extend Paperdragon::Model::Writer
    processable_writer :image
  end
end

