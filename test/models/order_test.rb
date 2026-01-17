require 'minitest/autorun'
require_relative '../../app/models/order'
require_relative '../../app/models/line_item'
require_relative '../../app/models/jewelry_item'

class OrderTest < Minitest::Test
  def test_total_calculation
    ji = JewelryItem.new(price_cents: 1000, name: 'Test')
    order = Order.new(status: 'pending')
    order.line_items.build(jewelry_item: ji, price_cents: ji.price_cents, quantity: 2)
    assert_equal 2000, order.total_cents
    assert_in_delta 20.0, order.total, 0.001
  end
end
