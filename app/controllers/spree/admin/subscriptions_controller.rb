module Spree
  module Admin
    class SubscriptionsController < ResourceController

      before_action :require_order_id, only: [:new]
      before_action :load_payment_methods, only: [:credit_card]

      def new
        order_id = params[:order_id]

        unless order_id.nil?
          order = Spree::Order.find(order_id)
          @subscription = build_subscription_from_order(order)

          # build subscription addresses
          user = order.user
          @subscription.build_ship_address(order.ship_address.dup.attributes.merge({user_id: user.id}))
          @subscription.build_bill_address(order.bill_address.dup.attributes.merge({user_id: user.id}))

          # build items
          build_subscription_items(@subscription, order)
        end
      end

      def create
        @subscription = Spree::Subscription.new(permitted_resource_params)
        build_subscription_items(@subscription, @subscription.orders.first)

        if @subscription.save
          flash[:success] = flash_message_for(@subscription, :subscription_created)

          redirect_to edit_object_url(@subscription)
        else
          flash[:error] = Spree.t(:subscription_could_not_be_created)

          render :new
        end
      end

      def renew
        before_failure_count = @object.failure_count
        ::GenerateSubscriptionOrder.new(@object).call

        # check if the failure count has increase, that means we have an error
        if  @object.failure_count > before_failure_count
          flash[:error] = flash_message_for(@object, :error_renew)
        else
          flash[:success] = flash_message_for(@object, :successfully_renewed)
        end
        respond_with(@object) do |format|
          format.html { redirect_to location_after_save }
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

      def skip
        if @object.skip_next_order
          flash[:success] = flash_message_for(@object, :successfully_skipped)
          respond_with(@object) do |format|
            format.html { redirect_to location_after_save }
          end
        end
      end

      def undo_skip
        if @object.undo_skip_next_order
          flash[:success] = flash_message_for(@object, :successfully_undo_skip)
          respond_with(@object) do |format|
            format.html { redirect_to location_after_save }
          end
        end
      end

      # creates a new credit card and attaches it to the subscription
      def credit_card
        if request.post?
          begin
            # get the payment_method_id
            credit_card_params = object_params[:source_attributes].merge Hash[*object_params.first]
            @object.add_new_credit_card(credit_card_params)
          rescue Spree::Core::GatewayError, CardStore::CardError => e
            flash[:error] = "#{e.message}"
          end

          redirect_to credit_card_admin_subscription_url(@object)
        end
      end

      def failures
        @subscriptions = Spree::Subscription.active.where('failure_count > 0').order('created_at desc')
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
            per(params[:per_page] || Spree::Config[:orders_per_page])

          @collection
        end

        def location_after_save
          edit_object_url(@object)
        end

      private
        def require_order_id
          if params[:order_id].blank?
            redirect_to admin_subscriptions_url
            flash[:error] = flash_message_for(@object, :requires_order_id)
          end
        end

        def build_subscription_from_order(order)
          attrs = {
            user_id: order.user.id,
            state: 'active',
            interval: order.subscription_interval,
            credit_card_id: order.credit_card_id_if_available
          }
          order.build_subscription(attrs)
        end

        def build_subscription_items(subscription, order)
          order.line_items.each do |line_item|
            subscription.subscription_items.build(
              subscription: subscription,
              variant: line_item.variant,
              quantity: line_item.quantity,
              price: line_item.price
            )
          end
        end

        def load_payment_methods
          @payment_methods = PaymentMethod.available(:back_end).select{ |method| method.type =~ /Gateway/ }
          @payment_method = @payment_methods.first
        end

        def object_params
          if params[:payment] and params[:payment_source] and source_params = params.delete(:payment_source)[params[:payment][:payment_method_id]]
            params[:payment][:source_attributes] = source_params
          end
          params.require(:payment).permit(permitted_payment_attributes)
        end

        def subscription_includes
          [:user, :orders]
        end
    end
  end
end
