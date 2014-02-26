class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :name
      t.string :value
      t.integer :location_id

      t.timestamps
    end
  end
end
