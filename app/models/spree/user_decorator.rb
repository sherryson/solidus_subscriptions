module Spree
  module UserExtensions

    def self.prepended(base)
      base.has_many :subscriptions

      base.has_many :log_entries, as: :source
    end

    def subscription_orders
      orders.joins(:subscription)
    end

    def subscription_addresses
      ::Spree::SubscriptionAddress.where(user: self)
    end

    def stripe_customer?
      return false if credit_cards.empty?
      credit_cards.map(&:gateway_customer_profile_id).grep(/^cus_/).present?
    end

    def stripe_id
      return unless stripe_customer?
      credit_cards.select { |c| c.gateway_customer_profile_id && c.gateway_customer_profile_id.include?('cus')}.last.gateway_customer_profile_id
    end

    def stripe_profile
      Stripe::Customer.retrieve(stripe_id)
    end

    def create_log_entry(response)
      log_entries.create!(:details => response.to_yaml)
    end
  end
end

::Spree::User.prepend Spree::UserExtensions
