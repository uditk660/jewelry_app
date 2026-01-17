class CreateMetalStockMovements < ActiveRecord::Migration[5.0]
  def change
    create_table :metal_stock_movements do |t|
      t.references :metal_stock, foreign_key: true, null: false
      t.integer :change_grams, null: false
      t.string :movement_type, null: false
      t.text :note

      t.timestamps
    end
  end
end
