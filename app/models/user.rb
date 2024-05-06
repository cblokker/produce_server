class User < ApplicationRecord
  # TODO: We can work on the naming to remind us:
  #       - buyers have orders
  #       - selelrs have inventory_items
  # Associations #
  has_many :inventory_items, foreign_key: :seller_id, dependent: :destroy
  has_many :orders, foreign_key: :buyer_id, dependent: :destroy

  # Validations #
  validates :name, presence: true

  # V2: Could add AASM gem to trigger buyer -> seller upgrade logic.
  # V2: Add Authorization layer (like cancancan or pundit), for seller & buyer roles
  # Enums #
  enum role: {
    buyer: 0,
    seller: 1
  }

  # Scopes #
  scope :selling_given_produce, -> (produce_ids) do
    joins(:inventory_items)    
      .where(inventory_items: { produce_id: produce_ids })
      .where('inventory_items.quantity > ?', 0)
      .group(:id)
  end

  # Methods #
  def has_inventory?
    inventory_quantity > 0
  end

  def inventory_quantity
    inventory_items.sum(:quantity)
  end

  def inventory_items_in_stock
    inventory_items.in_stock
  end
end
