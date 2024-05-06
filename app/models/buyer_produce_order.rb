class BuyerProduceOrder < ApplicationRecord
  # belongs_to :produce
  # belongs_to :buyer, class: 'User'

  def self.refresh
    Scenic.database.refresh_materialized_view(
      table_name,
      concurrently: true,
      cascade: false
    )
  end
end
