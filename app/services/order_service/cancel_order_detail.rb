module OrderService
  class CancelOrderDetail
    def initialize(order_detail:)
      @order_detail = order_detail
    end

    def call
      return false if order_detail.cancelled?

      refund_inventory_item
      cancel_order_detail
    end

    private

    attr_reader :order_detail

    def refund_inventory_item
      inventory_item.increment!(:quantity, order_detail.quantity)
    end

    # TODO: Can check if order is fully or partially cancelled, then do logic on order.
    #       But be careful with circular or inneficient state logic between associations.
    def cancel_order_detail
      order_detail.update(cancelled_at: DateTime.now)
    end

    def inventory_item
      @inventory_item ||= order_detail.inventory_item
    end
  end
end
