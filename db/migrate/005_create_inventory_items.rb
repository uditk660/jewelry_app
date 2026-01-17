class CreateInventoryItems < ActiveRecord::Migration[5.0]
  def change
    create_table :inventory_items do |t|
      t.references :jewelry_item, foreign_key: true, null: false
      t.integer :available_grams, null: false, default: 0
      t.string :location

      t.timestamps null: false
    end
  end
end
