module Spree
  class SubscriptionSkip < ActiveRecord::Base
    belongs_to :subscription, class_name: "Spree::Subscription", touch: true
  end
end