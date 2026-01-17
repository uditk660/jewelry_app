require 'minitest/autorun'
require_relative '../../app/models/inventory_item'
require_relative '../../app/models/jewelry_item'

class InventoryItemTest < Minitest::Test
  def test_adjust
    ji = JewelryItem.new(name: 'X', sku: 'X1', price_cents: 1000)
    ii = InventoryItem.new(jewelry_item: ji, available_grams: 100)
    ii.adjust!(10, movement_type: 'in', note: 'restock')
    assert_equal 110, ii.available_grams
  end
end
