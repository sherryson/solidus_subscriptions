class AddBillingAddressIdToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :bill_address_id, :integer
  end
end
