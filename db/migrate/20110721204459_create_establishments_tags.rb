class CreateEstablishmentsTags < ActiveRecord::Migration
  def change
    create_table :establishments_tags, :id => false do |t|
      t.integer :establishment_id
      t.integer :tag_id
    end
  end
end
