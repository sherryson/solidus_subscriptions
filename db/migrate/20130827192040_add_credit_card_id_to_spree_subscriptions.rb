class AddCreditCardIdToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :credit_card_id, :integer
    add_index :spree_subscriptions, :credit_card_id
  end
end
