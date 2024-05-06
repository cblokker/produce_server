class CreateProduces < ActiveRecord::Migration[7.1]
  def change
    create_table :produces do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :produces, :name, unique: true 
  end
end
