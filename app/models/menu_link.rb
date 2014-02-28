class MenuLink < ActiveRecord::Base
  belongs_to :location#, :inverse_of => :menu_links
  belongs_to :menu, :dependent => :destroy#, :inverse_of => :menu_links
end
