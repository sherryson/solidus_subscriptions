class AddCancelledAtToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :cancelled_at, :datetime
  end
end
