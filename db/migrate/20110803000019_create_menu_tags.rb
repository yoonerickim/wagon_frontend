class CreateMenuTags < ActiveRecord::Migration
  def change
    create_table :menu_tags do |t|
      t.string :name

      t.timestamps
    end
  end
end
