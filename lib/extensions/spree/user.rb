module SpreeSubscriptions
  module Extensions
    module Spree
      module User
        extend ActiveSupport::Concern

        included do
          has_many :subscriptions
        end

      end
    end
  end
end

::Spree::User.send(:include, SpreeSubscriptions::Extensions::Spree::User)
