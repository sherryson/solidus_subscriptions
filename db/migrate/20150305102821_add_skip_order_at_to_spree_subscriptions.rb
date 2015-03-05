class AddSkipOrderAtToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :skip_order_at, :datetime
  end
end
