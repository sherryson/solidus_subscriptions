module Spree
  module Api
    class SubscriptionsController < Spree::Api::BaseController
      before_action :find_subscription
      before_action :authenticate_user

      def skip_next_order
        @subscription.skip_next_order

        render json: @subscription.to_json
      end

      def undo_skip_next_order
        @subscription.undo_skip_next_order

        render json: @subscription.to_json
      end

      def cancel
        @subscription.cancel

        render json: @subscription.to_json
      end

      def show
        render json: @subscription.to_json
      end

      def update
        result = @subscription.update_attributes(subscription_params)

        if result
          render json: @subscription.to_json
        else
          invalid_resource!(@subscription)
        end
      end

      def update_address
        result = @subscription.update_attributes(subscription_params)

        if result
          # update the corresponding last order
          update_last_order_address

          render json: @subscription.to_json
        else
          invalid_resource!(@osubscriptionrder)
        end
      end

      private

      def update_last_order_address
        last_order = @subscription.last_order
        last_order.ship_address_id = @subscription.ship_address_id
        last_order.bill_address_id = @subscription.bill_address_id
        last_order.save
      end

      def find_subscription
        @subscription = Spree::Subscription.find(params[:id])
      end

      def subscription_params
        params.require(:subscription).permit(permitted_subscription_attributes)
      end

      def permitted_subscription_attributes
        [
          :interval, :bill_address_id, :ship_address_id, :credit_card_id
        ]
      end

    end
  end
end
