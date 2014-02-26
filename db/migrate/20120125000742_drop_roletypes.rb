class DropRoletypes < ActiveRecord::Migration
  def up
    drop_table :roletypes
  end

  def down
    create_table :roletypes do |t|
      t.string :name
    end
  end
end
