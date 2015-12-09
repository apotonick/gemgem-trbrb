class User < ActiveRecord::Base
  has_many :authorships
end