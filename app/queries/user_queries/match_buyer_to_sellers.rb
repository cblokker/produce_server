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

    # def buyers_preferred_produce_ids
    #   @buyers_preferred_produce_ids ||= query_results.as_json.pluck("seller_id").uniq
    # end

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


 # Could be useful as public


#  def query_results
#   @query_results ||= ActiveRecord::Base.connection.execute(
#     ApplicationRecord.sanitize_sql(
#       [sql, sql_query_params]
#     )
#   )
# end

# def sql_query_params
#   {
#     buyer_id: buyer.id,
#     time_window: "#{rolling_period_size} days" # TODO: Test singular '1 day' vs '1 days'
#   }
# end

# NOTE: Can make BUYER_PRODUCE_ORDERS a materialized view to store result & refresh on a 24 hr
#       period, since we're truncating down to the day. We probably dont want a client directly
#       passing in time_window because performance could be highly variable based on time_window.
# def sql
#   <<-SQL
#     WITH BUYER_PRODUCE_ORDERS AS (
#       SELECT
#         o.buyer_id,
#         ii.produce_id,
#         date_trunc('day', o.created_at) AS order_date,
#         LEAD(date_trunc('day', o.created_at)) OVER (
#           PARTITION BY o.buyer_id, ii.produce_id
#           ORDER BY date_trunc('day', o.created_at)
#         ) AS next_order_date
#       FROM
#         orders o
#       JOIN
#         order_details od ON o.id = od.order_id
#       JOIN
#         inventory_items ii ON od.inventory_item_id = ii.id
#       WHERE
#         o.cancelled_at IS NULL
#         AND
#         ii.quantity > 0
#         AND
#         o.buyer_id = :buyer_id
#     )
#     SELECT
#       buyer_id,
#       produce_id
#     FROM
#       BUYER_PRODUCE_ORDERS
#     WHERE
#       ((next_order_date - order_date) <= INTERVAL :time_window)
#     GROUP BY
#       buyer_id,
#       produce_id;
#   SQL
# end