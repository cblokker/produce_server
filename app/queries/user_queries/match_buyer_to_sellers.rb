module UserQueries
  class MatchBuyerToSellers
    DEFAULT_ROLLING_PERIOD_SIZE = 14

    def initialize(buyer:, rolling_period_size: DEFAULT_ROLLING_PERIOD_SIZE)
      @buyer = buyer
      @rolling_period_size = rolling_period_size
    end

    def call
      User.selling_given_produce(buyers_preferred_produce_ids)
    end

    private

    attr_reader :buyer, :rolling_period_size

    def buyers_preferred_produce_ids
      @buyers_preferred_produce_ids ||= BuyerProduceOrder
        .where(buyer_id: buyer.id)
        .where('((next_order_date - order_date) <= INTERVAL ?)', "#{rolling_period_size} days")
        .group(:produce_id)
        .pluck(:produce_id)
    end
  end
end
