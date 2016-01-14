module Spree
  module ProductExtensions

    def self.prepended(base)
      class << base
        prepend ClassMethods
      end
    end

    module ClassMethods
      def subscribable
        where(subscribable: true)
      end
    end
  end
end

::Spree::Product.prepend Spree::ProductExtensions
