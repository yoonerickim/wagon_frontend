class ChangeGpsDeliveryToSpotDeliveryOnLocations < ActiveRecord::Migration
  def change
    rename_column(:locations, :gps_delivery, :spot_delivery)
  end
end
