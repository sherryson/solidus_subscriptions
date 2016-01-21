module Spree
  class SubscriptionsController < Spree::StoreController
    before_action :find_subscription

    def pause
      @subscription.pause
      redirect_to :back
    end

    def resume
      @subscription.resume(resume_at_param)
      redirect_to :back
    end

    def cancel
      @subscription.cancel
      redirect_to :back
    end

    def update
      @subscription.bill_address_attributes=(address_params(:bill_address_attributes))
      @subscription.ship_address_attributes=(address_params(:ship_address_attributes))
      render :edit
    end

    private

    def find_subscription
      @subscription ||= Spree::Subscription.accessible_by(current_ability, :read).find(params[:id])
    end

    def resume_at_param
      Date.parse(params.require(:subscription).require(:resume_at))
    end

    private

    def address_params(address_attributes)
      params.require(:subscription).require(address_attributes).permit!
    end

  end
end
