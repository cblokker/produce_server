class Order < ApplicationRecord
  # Associations #
  belongs_to :buyer, class_name: 'User'
  has_many :order_details
  has_many :inventory_items, through: :order_details

  # Note: We could use a state machine gem like AASM to encapsulate state transition logic, as we
  #       can assume an order will most likely have many states.
  # Enums #
  enum :status, {
    pending: 0,
    completed: 1,
    cancelled: 2
  }
end
