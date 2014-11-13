class Thing < ActiveRecord::Base
  has_many :comments
  has_and_belongs_to_many :authors, association_foreign_key: :user_id, foreign_key: :thing_id, class_name: "User" # seriouslaaayyyyy?

  scope :latest, lambda { all.limit(3).order("id DESC") }
end

require_dependency "thing/crud"