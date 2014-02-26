class ItemTagLinks < ActiveRecord::Base
  belongs_to :item_tag
  belongs_to :menu_item
end
