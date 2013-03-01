module SpreeSubscriptions
  module Extensions
    module Spree
      module OrderPopulator
        extend ActiveSupport::Concern

        included do
          alias_method_chain :attempt_cart_add, :interval
        end

        def attempt_cart_add_with_interval(variant_id, options)
          return attempt_cart_add_without_interval(variant_id, options) unless options.is_a?(Hash)

          quantity = options[:quantity].to_i
          interval = options[:interval]

          variant = ::Spree::Variant.find(variant_id)

          if quantity > 0
            if check_stock_levels(variant, quantity)
              @order.add_variant(variant, quantity, interval, currency)
            end
          end
        end

      end
    end
  end
end

::Spree::OrderPopulator.send(:include, SpreeSubscriptions::Extensions::Spree::OrderPopulator)
