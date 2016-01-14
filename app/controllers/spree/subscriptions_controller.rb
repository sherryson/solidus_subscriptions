module Spree
  class SubscriptionsController < Spree::StoreController
    before_action :find_subscription

    def pause
      @subscription.pause
      redirect_to :back
    end

    def resume
      @subscription.resume

      redirect_to :back
    end


    private

    def find_subscription
      @subscription ||= Spree::Subscription.accessible_by(current_ability, :read).find(params[:id])
    end

  end
end
