module Spree
  module Api
    module CreditCardsControllerExtensions

      # create a new credit card
      # then assign it to the subscription
      def create_for_subscription
        subscription ||= Spree::Subscription.accessible_by(current_ability, :read).find(params[:subscription_id])
        order = subscription.last_order
        credit_card = nil
        begin
          ::Spree::CreditCard.transaction do
            credit_card = try_spree_current_user.credit_cards.build(credit_card_params)
            credit_card.save

            subscription.credit_card = credit_card
            subscription.save

            CardStore.store_card_for_user(try_spree_current_user, credit_card, credit_card.verification_value)
          end
          render json: subscription,
            scope: try_spree_current_user,
            serializer: SubscriptionSerializer,
            root: false
        rescue CardStore::CardError
          @resource = credit_card
          render "sprangular/errors/invalid", status: 422
        end
      end

      private

      def credit_card_params
        params.require(:credit_card).permit!
      end
    end
  end
end

Spree::Api::CreditCardsController.prepend Spree::Api::CreditCardsControllerExtensions