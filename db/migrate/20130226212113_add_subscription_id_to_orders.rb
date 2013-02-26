class AddSubscriptionIdToOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :subscription_id, :integer
  end
end
