class AddResumeOnFieldToSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :resume_on, :datetime
  end
end
