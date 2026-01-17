class CreateStockMovements < ActiveRecord::Migration[5.0]
  def change
    create_table :stock_movements do |t|
      t.references :inventory_item, foreign_key: true, null: false
      t.integer :change_grams, null: false
      t.string :movement_type, null: false # :in, :out, :adjustment
      t.string :note
      t.timestamps null: false
    end
  end
end
