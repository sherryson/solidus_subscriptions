module Spree
  class SubscriptionsController < Spree::StoreController
    before_action :find_subscription

    def pause
      @subscription.pause

      redirect_to :back
    end

    def find_subscription
      @subscription ||= Spree::Subscription.accessible_by(current_ability, :read).find(params[:id])
    end

  end
end
