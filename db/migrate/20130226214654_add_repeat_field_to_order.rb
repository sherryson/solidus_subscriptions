class AddRepeatFieldToOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :repeat_order, :boolean, default: false
  end
end
