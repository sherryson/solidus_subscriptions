class AddPauseAndResumeAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :pause_at, :datetime, default: nil
    add_column :spree_subscriptions, :resume_at, :datetime, default: nil
  end
end
