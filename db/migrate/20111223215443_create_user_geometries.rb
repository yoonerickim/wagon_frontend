class CreateUserGeometries < ActiveRecord::Migration
  def change
    create_table :user_geometries do |t|
      t.float :lat
      t.float :lng
      t.integer :user_id

      t.timestamps
    end
  end
end
