class AddRenewedAtSubscriptionSkips < ActiveRecord::Migration
  def change
    add_column :spree_subscription_skips, :renewed_at, :datetime
  end
end
