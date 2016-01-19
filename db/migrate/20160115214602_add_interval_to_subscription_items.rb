class AddIntervalToSubscriptionItems < ActiveRecord::Migration
  def change
    return if column_exists? :spree_subscription_items, :interval
    add_column :spree_subscription_items, :interval, :integer, default: 0
  end
end
