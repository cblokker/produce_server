require 'rails_helper'

RSpec.describe OrderDetail, type: :model do
  describe "Associations" do
    it { should belong_to(:order) }
    it { should belong_to(:inventory_item) }
    it { should have_one(:seller).through(:inventory_item) }
    it { should have_one(:buyer).through(:order) }
  end

  describe "Validations" do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:unit_price) }
  end

  describe "#cancelled?" do
    let(:order_detail) { create(:order_detail) }
    let(:cancelled_order_detal) { create(:order_detail, cancelled_at: DateTime.now) }
    
    context "when cancelled_at is present" do
      it "returns true" do
        expect(cancelled_order_detal.cancelled?).to be_truthy
      end
    end

    context "when cancelled_at is not present" do
      it "returns false" do
        expect(order_detail.cancelled?).to be_falsey
      end
    end
  end
end
