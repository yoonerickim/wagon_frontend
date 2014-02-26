class AddTitleToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :title, :string
  end
end
