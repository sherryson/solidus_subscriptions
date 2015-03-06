class CreateSubscriptionItems < ActiveRecord::Migration
  def change
    create_table :spree_subscription_items do |t|
      t.references :subscription
      t.references :variant

      t.integer    :quantity,             :null => false
      t.decimal    :price,                :precision => 8, :scale => 2, :null => false
      t.string     :currency

      t.decimal    :cost_price,           :precision => 8, :scale => 2, :null => false, default: 0.0
      t.integer    :tax_category_id
      t.decimal    :adjustment_total,     :precision => 8, :scale => 2, :null => false, default: 0.0
      t.decimal    :additional_tax_total, :precision => 8, :scale => 2, :null => false, default: 0.0
      t.decimal    :promo_total,          :precision => 8, :scale => 2, :null => false, default: 0.0
      t.decimal    :included_tax_total,   :precision => 8, :scale => 2, :null => false, default: 0.0
      t.decimal    :pre_tax_amount,       :precision => 8, :scale => 2, :null => false, default: 0.0      

      t.timestamps
    end
  end
end