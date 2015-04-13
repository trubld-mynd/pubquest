class CreateUsers < ActiveRecord::Migration
  def change

    create_table :users do |t|

      t.string :name
      t.string :name_profile_image_url
      t.integer :score
      t.timestamps
    end
  end
end
