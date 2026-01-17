require 'minitest/autorun'
require_relative '../../app/models/jewelry_item'

class JewelryItemTest < Minitest::Test
  def test_price_assignment
    item = JewelryItem.new
    item.price = 19.99
    assert_equal 1999, item.price_cents
  end
end
