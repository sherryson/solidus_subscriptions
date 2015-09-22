module Spree
  module UserExtensions

    def self.prepended(base)
      base.has_many :subscriptions
    end

    def subscription_orders
      orders.joins(:subscription)
    end

    def subscription_addresses
      ::Spree::SubscriptionAddress.where(user: self)
    end
  end
end

::Spree::User.prepend Spree::UserExtensions
