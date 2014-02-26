class AddTaxRateToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :tax_rate, :float, :default => 0
  end
end
