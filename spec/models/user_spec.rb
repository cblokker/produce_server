require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:seller) { create(:user, role: :seller) }
  let!(:buyer) { create(:user, role: :buyer) }
  let!(:inventory_item_in_stock) { create(:inventory_item, seller: seller, quantity: 5) }
  let!(:inventory_item_out_of_stock) { create(:inventory_item, seller: seller, quantity: 0) }

  describe "Associations" do
    it { should have_many(:inventory_items).dependent(:destroy).with_foreign_key(:seller_id) }
    it { should have_many(:orders).dependent(:destroy).with_foreign_key(:buyer_id) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
  end

  describe "Enums" do
    it { should define_enum_for(:role).with_values(buyer: 0, seller: 1) }
  end

  describe "Scopes" do
    it "returns sellers selling given produce" do
      produce_ids = [inventory_item_in_stock.produce_id, inventory_item_out_of_stock.produce_id]
      expect(User.selling_given_produce(produce_ids)).to include(seller)
      expect(User.selling_given_produce(produce_ids)).not_to include(buyer)
    end
  end

  describe "Methods" do
    it "returns true if user has inventory" do
      expect(seller.has_inventory?).to be_truthy
    end

    it "returns false if user has no inventory" do
      inventory_item_in_stock.update(quantity: 0)
      expect(buyer.has_inventory?).to be_falsey
    end

    it "returns total inventory quantity" do
      expect(seller.inventory_quantity).to eq(5)
    end

    it "returns inventory items in stock" do
      expect(seller.inventory_items_in_stock).to include(inventory_item_in_stock)
      expect(seller.inventory_items_in_stock).not_to include(inventory_item_out_of_stock)
    end
  end
end
