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
