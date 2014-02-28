class CreateEstablishments < ActiveRecord::Migration
  def change
    create_table :establishments do |t|
      t.integer :company_id
      t.string :description
      t.string :phone

      t.timestamps
    end
  end
end
