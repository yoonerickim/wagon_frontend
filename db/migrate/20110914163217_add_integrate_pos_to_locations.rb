class AddIntegratePosToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :integrate_pos, :boolean
  end
end
