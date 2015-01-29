class Thing < ActiveRecord::Base
  has_many :comments

  scope :latest, lambda { all.limit(9).order("id DESC") }
end
