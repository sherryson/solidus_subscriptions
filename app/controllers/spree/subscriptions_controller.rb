module Spree
  class SubscriptionsController < Spree::StoreController
    before_action :find_subscription, except: [:index]
    before_action :load_payment_methods, only: [:credit_card]

    def index
      @subscriptions = Spree::Subscription.accessible_by(current_ability, :read)
    end

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
      @subscription.attributes = resource_params
      render :edit
    end

    def add_item
      variant = Spree::Variant.accessible_by(current_ability, :read).find(params[:variant_id])

      return unless variant.product.subscribable?
      ::Spree::SubscriptionItem.create!(
        subscription: @subscription,
        variant: variant,
        quantity: 1,
        interval: @subscription.interval
      )
      render :edit
    end

    def credit_card
      if request.post?
        params = credit_card_params[:source_attributes].merge Hash[*credit_card_params.first]
        @subscription.add_new_credit_card(params)
      end
    end

    private

    def find_subscription
      @subscription = Spree::Subscription.accessible_by(current_ability, :read).find(params[:id])
    end

    def load_payment_methods
      @payment_methods = PaymentMethod.available(:back_end).select{ |method| method.type =~ /Gateway/ }
      @payment_method = @payment_methods.first
    end

    private

    def resource_params
      params.require(:subscription).permit!
    end

    def resume_at_param
      Date.parse(params.require(:subscription).require(:resume_at))
    end

    def credit_card_params
      if params[:payment] and params[:payment_source] and source_params = params.delete(:payment_source)[params[:payment][:payment_method_id]]
        params[:payment][:source_attributes] = source_params
      end
      params.require(:payment).permit(permitted_payment_attributes)
    end
  end
end
