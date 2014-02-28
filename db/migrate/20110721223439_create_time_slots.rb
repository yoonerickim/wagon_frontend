class CreateTimeSlots < ActiveRecord::Migration
  def change
    create_table :time_slots do |t|
      t.string :day
      t.boolean :closed
      t.time :open
      t.time :close

      t.integer :establishment_id

      t.timestamps
    end
  end
end
