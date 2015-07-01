module Spree
  module Admin
    class SubscriptionsController < ResourceController
      def index
        params[:q]     ||= {}
        params[:q][:s] ||= 'created_at desc'

        @search = Subscription.ransack(params[:q])
        @subscriptions = @search.result.includes([:user, :orders]).
          page(params.fetch(:page, 1)).
          per(params.fetch(:per_page, Spree::Config[:orders_per_page]))

        respond_with(@subscriptions)
      end

      def renew
        failure_count = @object.failure_count
        ::GenerateSubscriptionOrder.new(@object).call

        # check if the failure count has increase, that means we have an error
        if failure_count != @object.failure_count
          # send a renewal failure notice
          failed_order = @object.orders.reorder('created_at desc').first
          log = SubscriptionLog.find_by_order_id(failed_order.id)
          SubscriptionMailer.renewal_failure(@object, log.reason).deliver

          flash[:error] = flash_message_for(@object, :error_renew)
        else
          flash[:success] = flash_message_for(@object, :successfully_renewed)
        end
        respond_with(@object) do |format|
          format.html { redirect_to collection_url }
        end
      end

      def cancel
        if @object.cancel
          flash[:success] = flash_message_for(@object, :successfully_cancelled)
          respond_with(@object) do |format|
            format.html { redirect_to collection_url }
          end
        end
      end
    end
  end
end
