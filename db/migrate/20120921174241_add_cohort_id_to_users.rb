class AddCohortIdToUsers < ActiveRecord::Migration
  def change
    add_column(:users, :cohort_id, :string)
  end
end
