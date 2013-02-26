class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :spree_subscriptions do |t|
      t.references :user
      t.integer :ship_address_id
      t.string :state

      t.timestamps
    end
    add_index :spree_subscriptions, :user_id
  end
end
