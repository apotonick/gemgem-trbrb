class CreateCacheables < ActiveRecord::Migration
  def change
    create_table :cache_versions do |t|
      t.string :name
      t.timestamps
    end

    add_index :cache_versions, :name, unique: true
  end
end