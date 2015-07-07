module Spree
  module Admin
    class SubscriptionsController < ResourceController
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

      protected
        def collection
          return @collection if defined?(@collection)
          params[:q] ||= HashWithIndifferentAccess.new
          params[:q][:s] ||= 'id desc'

          @collection = super
          @search = @collection.ransack(params[:q])
          @collection = @search.result(distinct: true).
            includes(subscription_includes).
            page(params[:page]).
            per(params[:per_page] || Spree::Config[:promotions_per_page])

          @collection
        end     

        def subscription_includes
          [:user, :orders]
        end         
    end
  end
end
