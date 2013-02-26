module SpreeSubscriptions
  module Extensions
    module Spree
      module Product
        extend ActiveSupport::Concern

        included do
          attr_accessible :subscribable
        end

      end
    end
  end
end

::Spree::Product.send(:include, SpreeSubscriptions::Extensions::Spree::Product)
