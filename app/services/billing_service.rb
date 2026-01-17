class BillingService
  # Simple mock billing service - replace with real gateway integration
  def initialize(order, payment_info = {})
    @order = order
    @payment_info = payment_info
  end

  def charge!
    # Basic validation of payment info
    if @payment_info['card_number'].to_s.strip.empty?
      return { success: false, error: 'missing card number' }
    end

    # Simulate a charge: succeed for test card numbers, fail otherwise
    if @payment_info['card_number'].to_s.end_with?('4242')
      { success: true, transaction_id: "txn_#{SecureRandom.hex(8)}" }
    else
      { success: false, error: 'card declined' }
    end
  end
end
