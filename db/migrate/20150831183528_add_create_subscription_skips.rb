class AddCreateSubscriptionSkips < ActiveRecord::Migration
  def up
    create_table :spree_subscription_skips do |t|
      t.references :subscription

      t.datetime :skip_at
      t.datetime :undo_at

      t.timestamps
    end

    # copy existing skip_order_at information
    Spree::Subscription.all.each do |subscription|
      next if subscription.skip_order_at.nil?
      Spree::SubscriptionSkip.create(subscription: subscription, skip_at: subscription.skip_order_at)
    end

    # delete the old column
    remove_column :spree_subscriptions, :skip_order_at
  end

  def down
    add_column :spree_subscriptions, :skip_order_at, :datetime

    Spree::SubscriptionSkip.all.each do |skip|
      next if skip.undo_at
      skip.subscription.update_attribute(:skip_order_at, skip.skip_at)
    end

    drop_table :spree_subscription_skips
  end
end
