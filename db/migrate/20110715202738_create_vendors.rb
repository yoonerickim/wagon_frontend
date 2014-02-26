class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :website
      t.string :phone

      t.timestamps
    end
  end
end
