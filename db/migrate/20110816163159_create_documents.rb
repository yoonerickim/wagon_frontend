class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.text :description
      t.string :file_uid
      t.integer :documentable_id
      t.string :documentable_type

      t.timestamps
    end
  end
end
