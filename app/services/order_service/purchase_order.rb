module OrderService
  class PurchaseOrder
    class InvalidItemError < StandardError; end
    class NoInventoryProvidedError < StandardError; end
    class InsufficientQuantityError < StandardError; end

    # Note: consider using dry-rb for validations & types https://dry-rb.org/
    def initialize(buyer_id:, inventory_items_with_quantities: [])
      @buyer_id = buyer_id
      @inventory_items_with_quantities = inventory_items_with_quantities
    end

    def call
      raise NoInventoryProvidedError, "No Inventory Selected" if inventory_items_with_quantities.empty?

      precompute_order_inventory_items_data

      ActiveRecord::Base.transaction do
        create_order
        create_order_details
        decrement_inventory_quantities
        # payments
        # email_and_sms
      end
    rescue ActiveRecord::RecordNotFound => e
      raise InvalidItemError, "Item not found: #{e.message}"
    rescue ActiveRecord::RecordInvalid => e
      raise InvalidItemError, "Record invalid: #{e.message}"
    end

    private

    attr_reader :buyer_id,
                :inventory_items_with_quantities,
                :inventory_items_data,
                :total_order_price,
                :order,
                :order_details

    # TODO: Since we're computing total_order_price in memory, we want to confirm that
    #       order.total_price == order_details.sum(quantity * inventory_item.unit_price) at a strict level
    #       Alternatively, we could create an on_create callback to do the computation.
    def precompute_order_inventory_items_data
      raise InvalidItemError, "Invalid Inventory ids provided" if inventory_items_hash.empty?
      @inventory_items_data = []
      @total_order_price = 0.00

      inventory_items_with_quantities.each do |item|
        quantity = item[:quantity]
        inventory_item = inventory_items_hash[item[:inventory_item_id]]

        if inventory_item.quantity < quantity
          raise InsufficientQuantityError,
            "Insufficient quantity for #{inventory_item.produce.name} Abort Order"
        end

        @total_order_price += (quantity * inventory_item.unit_price)

        @inventory_items_data << {
          id: inventory_item.id,
          quantity: inventory_item.quantity - quantity
        }
      end
    end

    def create_order
      @order ||= Order.create!(buyer_id: buyer_id, total_price: total_order_price)
    end

    # CAUTION: These inserts/upserts bypass model validations
    def create_order_details
      @order_details ||= OrderDetail.insert_all(order_details_data)
    end

    def decrement_inventory_quantities
      InventoryItem.upsert_all(inventory_items_data, unique_by: :id)
    end

    def inventory_items_hash
      @inventory_items_hash ||= InventoryItem
        .where(id: inventory_items_with_quantities.pluck(:inventory_item_id))
        .index_by(&:id)
    end

    def order_details_data
      @order_details_data ||= inventory_items_with_quantities.map do |item|
        {
          inventory_item_id: item[:inventory_item_id],
          unit_price: inventory_items_hash[item[:inventory_item_id]].unit_price,
          quantity: item[:quantity],
          order_id: order.id
        }
      end
    end
  end
end
