class CreateSubscriptionAddresses < ActiveRecord::Migration
  def change
    create_table :spree_subscription_addresses do |t|
      t.string     :firstname
      t.string     :lastname
      t.string     :address1
      t.string     :address2
      t.string     :city
      t.string     :zipcode
      t.string     :phone
      t.string     :state_name
      t.string     :alternative_phone
      t.string     :company
      t.references :state
      t.references :country      
      t.references :user

      t.timestamps
    end
  end
end
