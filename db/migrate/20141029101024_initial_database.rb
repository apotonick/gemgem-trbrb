class InitialDatabase < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text    :body
      t.column  :weight, 'integer unsigned'

      t.integer :deleted

      t.integer :thing_id
      t.integer :user_id

      t.timestamps
    end

    create_table :things do |t|
      t.text :name
      t.text :description
      t.text :image_meta_data

      t.timestamps
    end

    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :confirmation_token
      t.text   :image_meta_data

      t.timestamps
    end

    create_table :authorships do |t|
      t.integer :user_id
      t.integer :thing_id
      t.integer :confirmed

      t.timestamps
    end


    create_join_table :things, :users do |t|
      # t.index [:thing_id, :user_id]
      # t.index [:user_id, :thing_id]
    end
  end
end
