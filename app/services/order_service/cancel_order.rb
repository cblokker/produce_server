# V2: Consider the use-case of partial cancelled orders on an order_details level, especially since
#     we allow a buyer to bundle one order across different sellers.
# V2: Depending on business use-case, for logistics, freighting, payout, & operation reasons, it may be better to
#     restrict buyers' orders to only one seller, to prevent overhead & future code complexity.
module OrderService
  class CancelOrder
    def initialize(order:)
      @order = order
    end

    def call
      return false if order.cancelled? || order.completed? # Only allow cancelling pending orders - consider adding aasm gem to order model

      ActiveRecord::Base.transaction do
        cancel_order
        cancel_order_details
        # payouts/refunds for buyer & seller
      end

      # email & sms

      true
    rescue => e
      raise StandardError.new("Error cancelling order number-#{order.id}: #{e.message}")
    end

    private

    attr_reader :order

    def cancel_order
      order.update!(status: :cancelled, cancelled_at: DateTime.now)
    end

    # TODO: Can build an upsert outside of OrderService::CancelOrderDetail to avoid the n+1
    #       and cancel all at once. Create a bulk/pluralized OrderService::CancelOrderDetails.new(ids).call.
    #       This may even allow an admin to cancel order_details across multiple orders at once. 
    def cancel_order_details
      order_details.each do |order_detail|
        OrderService::CancelOrderDetail.new(order_detail: order_detail).call
      end
    end

    def order_details
      @order_details ||= order.order_details.includes(:inventory_item)
    end
  end
end
