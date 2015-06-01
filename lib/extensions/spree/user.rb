module SpreeSubscriptions
  module Extensions
    module Spree
      module User

        def self.prepended(base)
          base.has_many :subscriptions, -> { order 'created_at desc' }
        end

        def subscription_orders
          orders.joins(:subscription)
        end

      end
    end
  end
end

::Spree::User.prepend SpreeSubscriptions::Extensions::Spree::User