module Spree
  module Api
    class SubscriptionItemsController < Spree::Api::BaseController
      before_action :find_subscription_item

      def update
        result = @subscription_item.update_attributes(subscription_items_params)

        if result
          render json: @subscription_item.to_json
        else
          invalid_resource!(@subscription_item)
        end
      end

      private

      def find_subscription_item        
        @subscription_item ||= Spree::SubscriptionItem.accessible_by(current_ability, :read).find(params[:id])
      end

      def subscription_items_params
        params.require(:subscription_item).permit(permitted_subscription_item_attributes)
      end

      def permitted_subscription_item_attributes
        [
          :quantity, :variant_id
        ]
      end
    end
  end
end
