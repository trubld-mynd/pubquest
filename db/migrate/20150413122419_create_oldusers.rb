class CreateOldusers < ActiveRecord::Migration
  def change
    create_table :oldusers do |t|
      t.string :name
      t.string :name_profile_image_url
      t.integer :score
      t.timestamps
    end
  end
end
