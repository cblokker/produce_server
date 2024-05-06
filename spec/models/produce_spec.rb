require 'rails_helper'

RSpec.describe Produce, type: :model do
  describe "Associations" do
    it { should have_many(:inventory_items).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
  end
end
