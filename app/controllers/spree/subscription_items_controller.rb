module Spree
  class SubscriptionItemsController < Spree::StoreController
    before_action :find_subscription

    def destroy
      @subscription.subscription_items.destroy(params[:id])
      redirect_to :back
    end

    private

    def find_subscription
      @subscription = Spree::Subscription.accessible_by(current_ability, :read).find(params[:id])
    end
  end
end
