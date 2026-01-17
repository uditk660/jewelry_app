require 'minitest/autorun'
require_relative '../../app/services/billing_service'
require_relative '../../app/models/order'

class BillingServiceTest < Minitest::Test
  def test_charge_success
    order = Order.new(status: 'pending')
    svc = BillingService.new(order, { 'card_number' => '4242' })
    result = svc.charge!
    assert result[:success]
  end

  def test_charge_fail_missing
    order = Order.new(status: 'pending')
    svc = BillingService.new(order, {})
    result = svc.charge!
    refute result[:success]
  end
end
