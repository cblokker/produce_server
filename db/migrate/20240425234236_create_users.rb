class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.integer :role, null: false, default: 0
      t.timestamps
    end
  end
end
