require 'rails_helper'

RSpec.describe UserQueries::MatchBuyerToSellers, type: :service do
  describe "#call" do
    let!(:produce) { create_list(:produce, 10) }
    let(:hits_time_threshold_array) { [5.days.ago, 25.days.ago, 50.days.ago, 64.days.ago, 80.days.ago] } # min diff = 14 days
    let(:misses_time_threshold_array) { [5.days.ago, 25.days.ago, 50.days.ago, 65.days.ago, 85.days.ago] } # min diff = 15 days

    let!(:seller_0) { create(:user, role: :seller) }
    let!(:seller_1) { create(:user, role: :seller) }
    let!(:seller_2) { create(:user, role: :seller) }
    let!(:seller_3) { create(:user, role: :seller) }

    let!(:buyer_0) { create(:user, role: :buyer) }
    let!(:buyer_1) { create(:user, role: :buyer) }
    let!(:buyer_2) { create(:user, role: :buyer) }
    let!(:buyer_3) { create(:user, role: :buyer) }
    let!(:buyer_4) { create(:user, role: :buyer) }


    # Inventory for seller_0
    let!(:inventory_item_0) { create(:inventory_item, quantity: 100, unit_price: 0.99, produce: produce[0], seller: seller_0) } # unique
    let!(:inventory_item_1) { create(:inventory_item, quantity: 100, unit_price: 1.29, produce: produce[1], seller: seller_0) } # shared with seller 2, 3, and 4
    let!(:inventory_item_2) { create(:inventory_item, quantity: 100, unit_price: 2.99, produce: produce[2], seller: seller_0) } # unique

    # Inventory for seller_1
    let!(:inventory_item_3) { create(:inventory_item, quantity: 100, unit_price: 0.79, produce: produce[1], seller: seller_1) } # shared with seller 1, 3, and 4
    let!(:inventory_item_4) { create(:inventory_item, quantity: 100, unit_price: 4.79, produce: produce[4], seller: seller_1) } # unique
    let!(:inventory_item_5) { create(:inventory_item, quantity: 100, unit_price: 1.09, produce: produce[5], seller: seller_1) } # unique

    # Inventory for seller_2
    let!(:inventory_item_6) { create(:inventory_item, quantity: 100, unit_price: 1.00, produce: produce[1], seller: seller_2) } # shared with seller 1, 2, and 4
    let!(:inventory_item_7) { create(:inventory_item, quantity: 100, unit_price: 2.66, produce: produce[3], seller: seller_2) } # unique
    let!(:inventory_item_8) { create(:inventory_item, quantity: 100, unit_price: 5.43, produce: produce[7], seller: seller_2) } # shared with seller 4
    let!(:inventory_item_9) { create(:inventory_item, quantity: 100, unit_price: 0.99, produce: produce[8], seller: seller_2) } # unique

    # Inventory for seller_3
    let!(:inventory_item_10) { create(:inventory_item, quantity: 100, unit_price: 1.01, produce: produce[1], seller: seller_3) } # shared with seller 1, 2, and 3
    let!(:inventory_item_11) { create(:inventory_item, quantity: 100, unit_price: 4.44, produce: produce[7], seller: seller_3) } # shared with seller 3

    before do
      # Create orders for buyer_0: hits
      hits_time_threshold_array.each do |created_at|
        create(:order, buyer_id: buyer_0.id, created_at: created_at).tap do |order|
          create(:order_detail, order: order, inventory_item: inventory_item_0, created_at: created_at)
          create(:order_detail, order: order, inventory_item: inventory_item_8, created_at: created_at)
        end

        create(:order, buyer_id: buyer_0.id, created_at: created_at).tap do |order|
          create(:order_detail, order: order, inventory_item: inventory_item_2, created_at: created_at)
        end
      end

      # Creates orders for buyer_1: hits
      misses_time_threshold_array.each do |created_at|
        create(:order, buyer_id: buyer_1.id, created_at: created_at).tap do |order|
          create(:order_detail, order: order, inventory_item: inventory_item_0, created_at: created_at)
          create(:order_detail, order: order, inventory_item: inventory_item_8, created_at: created_at)
        end

        create(:order, buyer_id: buyer_1.id, created_at: created_at).tap do |order|
          create(:order_detail, order: order, inventory_item: inventory_item_2, created_at: created_at)
        end
      end

      (misses_time_threshold_array.map { |time| time + 3.days }).each do |created_at|
        create(:order, buyer_id: buyer_1.id, created_at: created_at).tap do |order|
          create(:order_detail, order: order, inventory_item: inventory_item_0, created_at: created_at)
          create(:order_detail, order: order, inventory_item: inventory_item_8, created_at: created_at)
          create(:order_detail, order: order, inventory_item: inventory_item_4, created_at: created_at) # missed for this inventory_item
        end
      end

      # Create orders for buyer_2: misses
      misses_time_threshold_array.each do |created_at|
        create(:order, buyer_id: buyer_2.id, created_at: created_at).tap do |order|
          create(:order_detail, order: order, inventory_item: inventory_item_0, created_at: created_at)
          create(:order_detail, order: order, inventory_item: inventory_item_8, created_at: created_at)
        end

        create(:order, buyer_id: buyer_2.id, created_at: created_at).tap do |order|
          create(:order_detail, order: order, inventory_item: inventory_item_2, created_at: created_at)
        end
      end

      # Create orders for buyer_3: misses - ignrores cancelled at
      create(:order, buyer_id: buyer_3.id, created_at: 1.days.ago).tap do |order|
        create(:order_detail, order: order, inventory_item: inventory_item_8, created_at: 5.days.ago)
      end

      create(:order, buyer_id: buyer_3.id, created_at: 7.days.ago, status: :cancelled, cancelled_at: DateTime.now).tap do |order|
        create(:order_detail, order: order, inventory_item: inventory_item_8, created_at: 7.days.ago, cancelled_at: DateTime.now)
      end

      create(:order, buyer_id: buyer_3.id, created_at: 16.days.ago).tap do |order|
        create(:order_detail, order: order, inventory_item: inventory_item_8, created_at: 16.days.ago)
      end

      # Create orders for buyer_4: misses - ignrores cancelled at
      create(:order, buyer_id: buyer_4.id, created_at: 1.day.ago).tap do |order|
        create(:order_detail, order: order, inventory_item: inventory_item_0, created_at: 1.day.ago)
      end

      create(:order, buyer_id: buyer_4.id, created_at: 2.days.ago).tap do |order|
        create(:order_detail, order: order, inventory_item: inventory_item_1, created_at: 2.days.ago)
      end

      create(:order, buyer_id: buyer_4.id, created_at: 3.days.ago).tap do |order|
        create(:order_detail, order: order, inventory_item: inventory_item_2, created_at: 3.days.ago)
      end
    end

    context 'when there is a match' do
      it "returns sellers matching the buyer's purchase history within the rolling period" do
        result = UserQueries::MatchBuyerToSellers.new(buyer: buyer_0).call
        expect(result).to contain_exactly(seller_0, seller_2, seller_3)
      end

      it "returns sellers matching the buyer's purchase history within the rolling period" do
        result = UserQueries::MatchBuyerToSellers.new(buyer: buyer_1).call
        expect(result).to contain_exactly(seller_0, seller_2, seller_3)
      end
    end

    context 'when there is not a match' do
      it "returns no preferred sellers when orders are too spaced out" do
        result = UserQueries::MatchBuyerToSellers.new(buyer: buyer_2).call
        expect(result).to eq([])
      end

      it "returns no preferred sellers when orders are within rolling period, but it is cancelled" do
        result = UserQueries::MatchBuyerToSellers.new(buyer: buyer_3).call
        expect(result).to eq([])
      end

      it "returns no preferred sellers when orders are within rolling period, but of different produce" do
        result = UserQueries::MatchBuyerToSellers.new(buyer: buyer_4).call
        expect(result).to eq([])
      end
    end
  end
end
