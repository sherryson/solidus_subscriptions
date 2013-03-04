class AddIntervalToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :interval, :integer, default: nil
  end
end
