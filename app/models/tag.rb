class Tag < ActiveRecord::Base
  has_many :tag_links
  has_many :locations, :through => :tag_links

  scope :standard, where(:standard => true).order('name ASC').all
  scope :extra, where('standard IS NULL OR standard = ?', false).order('name')
  scope :matching, lambda { |term| where("name ILIKE ?", "%#{term}%") }

  validates :name, :presence => true

end
