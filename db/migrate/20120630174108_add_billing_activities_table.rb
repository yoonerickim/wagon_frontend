class AddBillingActivitiesTable < ActiveRecord::Migration
  def change
    create_table :billing_activities do |t|
      t.integer :order_id
      t.integer :user_id
      t.text :description
      t.integer :amount
       
      t.timestamps
    end
  end
end
