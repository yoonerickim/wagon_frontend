class AddOpenmenuFieldsToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :openmenu_url, :string
    add_column :locations, :use_openmenu_hours, :boolean
  end
end
