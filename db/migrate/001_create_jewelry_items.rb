class CreateJewelryItems < ActiveRecord::Migration[5.0]
  def change
    create_table :jewelry_items do |t|
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false, default: 0
      t.string :sku, null: false

      t.timestamps null: false
    end
    add_index :jewelry_items, :sku, unique: true
  end
end
