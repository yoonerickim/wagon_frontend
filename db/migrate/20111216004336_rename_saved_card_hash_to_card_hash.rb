class RenameSavedCardHashToCardHash < ActiveRecord::Migration
  def up
    rename_column :saved_cards, :hash, :card_hash
  end

  def down
    rename_column :saved_cards, :card_hash, :hash
  end
end
