class AddFailureCountToSpreeSubscriptions < ActiveRecord::Migration
  def change
    return if column_exists?(:spree_subscriptions, :failure_count)
    add_column :spree_subscriptions, :failure_count, :integer, default: 0
  end
end
