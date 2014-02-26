class MenuGroup < ActiveRecord::Base
  belongs_to :menu

  has_many :items, :class_name => 'MenuItem', :dependent => :destroy
  has_many :options, :as => :optionable, :class_name => 'MenuOption', :dependent => :destroy

  accepts_nested_attributes_for :items, allow_destroy: true
  accepts_nested_attributes_for :options, allow_destroy: true

  validates :name, presence: true

end
