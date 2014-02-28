class CreateGvendors < ActiveRecord::Migration
  def change
    create_table :gvendors do |t|
      t.string :name
      t.string :gid
      t.string :menu_url
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone
      t.float :lat
      t.float :lng

      t.timestamps
    end
    add_index("gvendors", "gid")
    add_index(:gvendors, [:lat, :lng])
  end
end
