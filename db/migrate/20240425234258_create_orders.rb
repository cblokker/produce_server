class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :buyer, foreign_key: { to_table: :users }
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.integer :status, default: 0, null: false
      t.datetime :cancelled_at
      t.datetime :completed_at
      t.timestamps
    end
  end
end
