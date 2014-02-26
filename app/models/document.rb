class Document < ActiveRecord::Base
  belongs_to :documentable, :polymorphic => true
  document_accessor :file

  # TODO figure out how to test dragonfly validations
  validates_property :format, :of => :file, :in => [:txt, :jpeg, :png, :doc, :docx, :pages, :csv, :xlsx, :xls, :numbers, :pdf]
end
