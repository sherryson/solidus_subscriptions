class AddPrepaidAmountToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :prepaid_amount, :decimal, default: 0.0, precision: 10, scale: 2
  end
end
