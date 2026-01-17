module MoneyHelper
  # Format an amount in rupees using the rupee symbol and two decimals.
  # Accepts numeric amounts already in rupees (not cents) or cents when :cents => true
  def format_rupees(amount, cents: false)
    return '' if amount.nil?
    value = cents ? (amount.to_f / 100.0) : amount.to_f
    # use Indian Rupee symbol
    "\u20B9#{'%.2f' % value}"
  end
end
