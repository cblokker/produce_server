require 'rails_helper'

RSpec.describe OrderService::PurchaseOrder do
  let(:buyer_id) { 43_111 }
  let!(:buyer) { create(:user, id: buyer_id, role: :buyer) }
  let!(:inventory_item_1) { create(:inventory_item, quantity: 10) }
  let!(:inventory_item_2) { create(:inventory_item, quantity: 5) }

  describe "#call" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          buyer_id: buyer_id,
          inventory_items_with_quantities:  [
            {
              inventory_item_id: inventory_item_1.id,
              quantity: 2
            },
            {
              inventory_item_id: inventory_item_2.id,
              quantity: 3
            }
          ]
        }
      end

      it "creates an order and order details" do
        expect { OrderService::PurchaseOrder.new(**valid_params).call }
          .to change { Order.count }.by(1)
          .and change { OrderDetail.count }.by(2)
          .and change { InventoryItem.find(inventory_item_1.id).quantity }.by(-2)
          .and change { InventoryItem.find(inventory_item_2.id).quantity }.by(-3)
      end
    end

    context "with no inventory items provided" do
      let(:params_with_no_inventory) do
        {
          buyer_id: buyer_id,
          inventory_items_with_quantities: []
        }
      end

      it "raises NoInventoryProvidedError" do
        expect { OrderService::PurchaseOrder.new(**params_with_no_inventory).call }
          .to raise_error(OrderService::PurchaseOrder::NoInventoryProvidedError)
      end
    end

    context "with insufficient quantity for an inventory item" do
      let(:params_with_insufficient_inventory) do
        {
          buyer_id: buyer_id,
          inventory_items_with_quantities: [
            {
              inventory_item_id: inventory_item_1.id,
              quantity: 100
            }
          ]
        }
      end

      it "raises InsufficientQuantityError" do
        expect { OrderService::PurchaseOrder.new(**params_with_insufficient_inventory).call }
          .to raise_error(OrderService::PurchaseOrder::InsufficientQuantityError)
      end
    end

    context "with invalid inventory item" do
      let(:params_invalid_inventory_item) do
        {
          buyer_id: buyer_id,
          inventory_items_with_quantities: [
            {
              inventory_item_id: InventoryItem.maximum(:id).to_i + 1,
              quantity: 1
            }
          ]
        }
      end

      it "raises InvalidItemError" do
        expect { OrderService::PurchaseOrder.new(**params_invalid_inventory_item).call }
          .to raise_error(OrderService::PurchaseOrder::InvalidItemError)
      end
    end
  end
end
