module UserQueries
  class MatchSellerToBuyers
    DEFAULT_ROLLING_PERIOD_SIZE = 14

    def initialize(seller:, rolling_period_size: DEFAULT_ROLLING_PERIOD_SIZE)
      @seller = seller # TODO: Validate is_seller?
      @rolling_period_size = rolling_period_size
    end

    def call
      User.where(id: produce_preferred_buyer_ids)
    end

    private

    attr_reader :seller, :rolling_period_size

    # NOTE: Made assumption we want same interval threshold on a buyers order profile
    #       to match against valid prospective buyers.
    def produce_preferred_buyer_ids
      @produce_preferred_buyer_ids ||= BuyerProduceOrder
        .where(produce_id: seller_produce_ids)
        .where('((next_order_date - order_date) <= INTERVAL ?)', "#{rolling_period_size} days")
        .group(:buyer_id)
        .pluck(:buyer_id)
    end

    def seller_produce_ids
      @seller_produce_ids ||= seller.inventory_items_in_stock.group(:produce_id).pluck(:produce_id)        
    end
  end
end
