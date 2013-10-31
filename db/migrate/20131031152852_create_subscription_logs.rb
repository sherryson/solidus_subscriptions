class CreateSubscriptionLogs < ActiveRecord::Migration
  def change
    create_table :subscription_logs do |t|
      t.integer :order_id
      t.text :reason

      t.timestamps
    end
  end
end
