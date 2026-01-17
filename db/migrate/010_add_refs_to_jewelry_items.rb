class AddRefsToJewelryItems < ActiveRecord::Migration[5.0]
  def change
    add_reference :jewelry_items, :metal, index: true
    add_reference :jewelry_items, :purity, index: true
    add_reference :jewelry_items, :jewellery_category, index: true
  end
end
