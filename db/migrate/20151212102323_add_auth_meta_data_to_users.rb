class AddAuthMetaDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auth_meta_data, :text
  end
end
