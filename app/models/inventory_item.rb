
class InventoryItem < ApplicationRecord
  # Associations #
  belongs_to :produce
  belongs_to :seller, class_name: 'User'
  has_many :order_details
  has_many :orders, through: :order_details

  # Validations #
  validates :unit_price, :quantity, presence: true

  # Scopes #
  scope :in_stock, -> { where('quantity > ?', 0) }
end
