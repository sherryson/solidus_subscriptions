module Spree
  class SubscriptionAddress < Spree::Address
    self.table_name = 'spree_subscription_addresses'  

    belongs_to :user
  end
end
