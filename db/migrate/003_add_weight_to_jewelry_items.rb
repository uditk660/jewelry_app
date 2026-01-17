class AddWeightToJewelryItems < ActiveRecord::Migration[5.0]
  def change
    add_column :jewelry_items, :weight_grams, :integer, null: false, default: 0
    add_column :jewelry_items, :metal_type, :string
  end
end
