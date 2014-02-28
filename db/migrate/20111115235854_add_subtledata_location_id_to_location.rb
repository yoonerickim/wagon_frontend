class AddSubtledataLocationIdToLocation < ActiveRecord::Migration
  def change
    add_column(:locations, :subtledata_location_id, :integer)
  end
end
