class AddTeriyakiAsTag < ActiveRecord::Migration
  def change
    Tag.create(:name => 'Teriyaki', :standard => true)
    add_column(:addresses, :lat,:float)
    add_column(:addresses, :lng,:float)
    add_index "addresses", ["lat", "lng"]
  end
end
