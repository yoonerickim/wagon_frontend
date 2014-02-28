class ItemTag < ActiveRecord::Base
  has_many :item_tag_links
  has_many :menu_items, :through => :item_tag_links

  validates :name, :presence => true
end
