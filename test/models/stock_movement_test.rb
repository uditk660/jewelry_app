require 'minitest/autorun'
require_relative '../../app/models/stock_movement'

class StockMovementTest < Minitest::Test
  def test_validation
    sm = StockMovement.new(change_grams: 5, movement_type: 'in')
    assert sm.valid?
  end
end
