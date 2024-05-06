class CreateInventoryItems < ActiveRecord::Migration[7.1]
  def change
    create_table :inventory_items do |t|
      t.references :seller, foreign_key: { to_table: :users }
      t.references :produce, foreign_key: true
      t.decimal :unit_price, precision: 10, scale: 2, null: false, default: 0.00
      t.integer :quantity, null: false, default: 0
      t.timestamps
    end

    add_index :inventory_items, [:seller_id, :produce_id], unique: true
  end
end
