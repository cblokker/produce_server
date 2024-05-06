require 'rails_helper'

RSpec.describe InventoryItem, type: :model do
  describe "Associations" do
    it { should belong_to(:produce) }
    it { should belong_to(:seller).class_name('User') }
    it { should have_many(:order_details) }
    it { should have_many(:orders).through(:order_details) }
  end

  describe "Validations" do
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:quantity) }
  end

  describe "Scopes" do
    describe ".in_stock" do
      let(:in_stock_item) { create(:inventory_item, quantity: 5) }
      let(:out_of_stock_item) { create(:inventory_item, quantity: 0) }

      it "returns inventory items with quantity greater than 0" do
        expect(InventoryItem.in_stock).to include(in_stock_item)
        expect(InventoryItem.in_stock).not_to include(out_of_stock_item)
      end
    end
  end
end