class RenameEstablishmentToLocation < ActiveRecord::Migration
  def up
    rename_table :establishments, :locations
    rename_table :establishments_tags, :locations_tags
    rename_column :locations_tags, :establishment_id, :location_id
    rename_column :time_slots, :establishment_id, :location_id
  end

  def down
    rename_table :locations, :establishments
    rename_table :locations_tags, :establishments_tags
    rename_column :establishments_tags, :location_id, :establishment_id
    rename_column :time_slots, :location_id, :establishment_id
  end
end
