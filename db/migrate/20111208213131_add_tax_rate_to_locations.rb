class AddTaxRateToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :tax_rate, :float, default: 0.095
  end
end
