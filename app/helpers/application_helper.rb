module ApplicationHelper
  include MoneyHelper
  # Some older/newer Rails versions provide csp_meta_tag helper.
  # Provide a safe no-op fallback so templates that include it won't break
  # when running on Rails versions that don't define it.
  def csp_meta_tag
    ''
  end

  # Fallback rupee formatter available to views.
  # If MoneyHelper is present this will be redundant, but guarantees availability.
  def format_rupees(amount, cents: false)
    return '' if amount.nil?
    value = cents ? (amount.to_f / 100.0) : amount.to_f
    "\u20B9#{'%.2f' % value}"
  end
end
