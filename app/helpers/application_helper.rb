module ApplicationHelper
  include MoneyHelper
  # Some older/newer Rails versions provide csp_meta_tag helper.
  # Provide a safe no-op fallback so templates that include it won't break
  # when running on Rails versions that don't define it.
  def csp_meta_tag
    ''
  end

  # Convert numeric amount to words (Indian numbering system).
  # Examples:
  #   number_to_words(1523.45) => "One thousand five hundred twenty three Rupees and Forty five Paise only"
  def number_to_words(amount)
    return '' if amount.nil?
    amt = amount.to_f.round(2)
    rupees = amt.to_i
    paise = ((amt - rupees) * 100).round

    words = []
    words << "#{convert_number_to_words(rupees)} Rupees" if rupees > 0
    words << "#{convert_number_to_words(paise)} Paise" if paise > 0

    if words.empty?
      "Zero Rupees only"
    else
      "#{words.join(' and ')} only"
    end
  end

  private

  def convert_number_to_words(number)
    return 'Zero' if number == 0
    units = %w(Zero One Two Three Four Five Six Seven Eight Nine Ten Eleven Twelve Thirteen Fourteen Fifteen Sixteen Seventeen Eighteen Nineteen)
    tens = %w(Zero Ten Twenty Thirty Forty Fifty Sixty Seventy Eighty Ninety)

    parts = []

    crores = number / 10000000
    number = number % 10000000
    if crores > 0
      parts << "#{convert_number_to_words(crores)} Crore"
    end

    lakhs = number / 100000
    number = number % 100000
    if lakhs > 0
      parts << "#{convert_number_to_words(lakhs)} Lakh"
    end

    thousands = number / 1000
    number = number % 1000
    if thousands > 0
      parts << "#{convert_number_to_words(thousands)} Thousand"
    end

    hundreds = number / 100
    number = number % 100
    if hundreds > 0
      parts << "#{units[hundreds]} Hundred"
    end

    if number > 0
      if !parts.empty?
        parts << 'and'
      end
      if number < 20
        parts << units[number]
      else
        t = number / 10
        u = number % 10
        parts << tens[t]
        parts << units[u] if u > 0
      end
    end

    parts.join(' ')
  end

  # Fallback rupee formatter available to views.
  # If MoneyHelper is present this will be redundant, but guarantees availability.
  def format_rupees(amount, cents: false)
    return '' if amount.nil?
    value = cents ? (amount.to_f / 100.0) : amount.to_f
    "\u20B9#{'%.2f' % value}"
  end
end
