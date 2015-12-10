class CacheVersion < ActiveRecord::Base
  def self.for(name)
     where(name: name).first or create(name: name)
  end

  def cache_key # called in AS::Cache#retrieve_cache_key.
    updated_at
  end

  def expire!
    update_attribute(:updated_at, (updated_at || Time.now) + 1.second)
  end
end