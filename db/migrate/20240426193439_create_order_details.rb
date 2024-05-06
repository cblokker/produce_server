class CreateOrderDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :order_details do |t|
      t.decimal :unit_price, precision: 10, scale: 2, null: false, default: 0.00
      t.integer :quantity, null: false, default: 0
      t.references :order, foreign_key: true
      t.references :inventory_item, foreign_key: true
      t.datetime :cancelled_at
      t.timestamps
    end

    add_index :order_details, [:order_id, :inventory_item_id], unique: true
  end
end
