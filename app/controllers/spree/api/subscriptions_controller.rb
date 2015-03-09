module Spree
  module Api
    class SubscriptionsController < Spree::Api::BaseController
      before_action :find_subscription

      def skip_next_order
        @subscription.skip_next_order    
        
        render json: @subscription.to_json        
      end      

      def undo_skip_next_order
        @subscription.undo_skip_next_order    
        
        render json: @subscription.to_json
      end

      def show
        render json: @subscription.to_json
      end    

      def update
        # authorize! :update, @order, order_token
        result = @subscription.update_attributes(subscription_params)

        if result          
          render json: @subscription.to_json
        else
          invalid_resource!(@osubscriptionrder)
        end
      end

      private

      def find_subscription
        @subscription = Spree::Subscription.find(params[:id])
      end

      def subscription_params
        params.require(:subscription).permit(permitted_subscription_attributes)
      end

      def permitted_subscription_attributes
        [
          :interval, :billing_address_id, :shipment_address_id
        ]
      end
        
    end
  end
end
