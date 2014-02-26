class AddAuthorIdToOrderNotes < ActiveRecord::Migration
  def change
    add_column(:order_notes, :author_id, :integer)
  end
end
