class OrderDetail < ApplicationRecord
  # Associations #
  belongs_to :order
  belongs_to :inventory_item

  has_one :seller, through: :inventory_item, foreign_key: :seller_id
  has_one :buyer, through: :order, foreign_key: :buyer_id

  # Validations #
  validates :quantity, :unit_price, presence: true

  def cancelled?
    cancelled_at.present?
  end
end
