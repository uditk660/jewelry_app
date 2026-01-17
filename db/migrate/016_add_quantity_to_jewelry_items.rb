class AddQuantityToJewelryItems < ActiveRecord::Migration[5.0]
  def change
    add_column :jewelry_items, :quantity, :integer, null: false, default: 0
  end
end
