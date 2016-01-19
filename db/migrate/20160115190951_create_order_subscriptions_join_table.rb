class CreateOrderSubscriptionsJoinTable < ActiveRecord::Migration
  def change
    return if table_exists? :spree_orders_subscriptions
    create_table :spree_orders_subscriptions, id: false do |t|
      t.integer :order_id
      t.integer :subscription_id
    end

    remove_column :spree_orders, :subscription_id if column_exists? :spree_orders, :subscription_id
  end
end
