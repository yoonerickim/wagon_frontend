class RefactorDeliverIdToAssignedToId < ActiveRecord::Migration
  def up
    rename_column :orders, :deliverer_id, :assigned_to_id
  end

  def down
    rename_column :orders, :assigned_to_id, :deliverer_id
  end
end
