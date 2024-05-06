require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "Associations" do
    it { should belong_to(:buyer).class_name('User') }
    it { should have_many(:order_details) }
    it { should have_many(:inventory_items).through(:order_details) }
  end

  describe "Enums" do
    it { should define_enum_for(:status).with_values(pending: 0, completed: 1, cancelled: 2) }
  end
end
