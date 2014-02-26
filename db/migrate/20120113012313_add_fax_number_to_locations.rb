class AddFaxNumberToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :fax_number, :string
  end
end
