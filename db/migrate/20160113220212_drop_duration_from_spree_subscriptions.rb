class DropDurationFromSpreeSubscriptions < ActiveRecord::Migration
  def change
    remove_column :spree_subscriptions, :duration
  end
end
