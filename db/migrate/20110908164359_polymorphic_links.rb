class PolymorphicLinks < ActiveRecord::Migration
  def up
    # Change to polymorphic links
    rename_column :links, :location_id, :linkable_id
    add_column :links, :linkable_type, :string
    Link.find_each do |link|
      link.update_attribute(:linkable_type, 'Location')
    end
  end

  def down
    # Change from polymorphic links
    rename_column :links, :linkable_id, :location_id
    Link.find_each do |link|
      link.destroy if link.linkable_id == 'Vendor'
    end
    remove_column :links, :linkable_type
  end
end
