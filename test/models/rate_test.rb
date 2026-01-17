require 'minitest/autorun'
require_relative '../../app/models/rate'

class RateTest < Minitest::Test
  def test_price_per_gram
    r = Rate.new(price_cents_per_gram: 1234)
    assert_in_delta 12.34, r.price_per_gram, 0.001
  end
end
