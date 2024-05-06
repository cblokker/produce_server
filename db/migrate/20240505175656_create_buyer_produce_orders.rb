class CreateBuyerProduceOrders < ActiveRecord::Migration[7.1]
  def change
    create_view :buyer_produce_orders # NOTE: Can make this materialized to speed up query,
                                      #       but need to think when to refresh to capture cancelled &
                                      #       new orders coming in, without refreshing too frequnetly.
  end
end
