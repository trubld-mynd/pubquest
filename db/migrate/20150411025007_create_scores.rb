class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|

      t.timestamps
      t.string :name
      t.integer :score
    end
  end
end
