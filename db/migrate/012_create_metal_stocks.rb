class CreateMetalStocks < ActiveRecord::Migration[5.0]
  def change
    create_table :metal_stocks do |t|
      t.references :metal, foreign_key: true, null: false
      t.references :store, foreign_key: true, null: false
      t.integer :available_grams, null: false, default: 0
      t.integer :price_cents_per_gram, null: false, default: 0

      t.timestamps
    end

    add_index :metal_stocks, [:metal_id, :store_id], unique: true
  end
end
