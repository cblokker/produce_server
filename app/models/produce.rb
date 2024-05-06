class Produce < ApplicationRecord
  # Associations #
  has_many :inventory_items, dependent: :destroy
  has_many :buyer_interests
  has_many :seller_interests

  # Validations #
  validates :name, presence: true, uniqueness: true
end
