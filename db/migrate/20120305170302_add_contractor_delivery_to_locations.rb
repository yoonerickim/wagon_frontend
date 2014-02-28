class AddContractorDeliveryToLocations < ActiveRecord::Migration
  def change
    add_column(:locations, :contractor_delivery, :boolean, :default => true)
  end
end
