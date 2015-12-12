class User < ActiveRecord::Base
  has_many :authorships
  has_many :comments

  serialize :auth_meta_data
end