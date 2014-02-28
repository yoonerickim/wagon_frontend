class MenuOption < ActiveRecord::Base
  belongs_to :optionable, :polymorphic => true
  has_many :option_items, :class_name => "MenuOptionItem", :dependent => :destroy

  has_many :line_item_options, through: :option_items
  has_many :line_items, through: :line_item_options

  accepts_nested_attributes_for :option_items

  validates :name, presence: true
end
