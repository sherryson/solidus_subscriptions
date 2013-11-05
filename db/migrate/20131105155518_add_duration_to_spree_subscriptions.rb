class AddDurationToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :duration, :integer
  end
end
