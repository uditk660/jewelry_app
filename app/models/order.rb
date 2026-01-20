class Order < ActiveRecord::Base
  has_many :line_items, dependent: :destroy
  belongs_to :customer, optional: true
  validates :status, presence: true

  before_create :set_invoice_and_date

  after_update :decrement_inventory_on_payment

  STATUSES = %w[pending paid failed cancelled]

  # Default tax rates (percent)
  DEFAULT_CGST_RATE = 1.5
  DEFAULT_IGST_RATE = 1.5

  def total_cents
    line_items.sum('price_cents * quantity')
  end

  # Return the CGST rate for this order, falling back to the default if not set
  def cgst_rate_or_default
    (self.cgst_rate.present? && self.cgst_rate.to_f > 0) ? self.cgst_rate.to_f : DEFAULT_CGST_RATE
  end

  # Return the IGST rate for this order, falling back to the default if not set
  def igst_rate_or_default
    (self.igst_rate.present? && self.igst_rate.to_f > 0) ? self.igst_rate.to_f : DEFAULT_IGST_RATE
  end

  def total
    total_cents.to_f / 100.0
  end

  def add_item(jewelry_item, quantity = 1)
    li = line_items.find_by(jewelry_item_id: jewelry_item.id)
    if li
      li.quantity += quantity
      li.price_cents = jewelry_item.price_cents
      li.save
    else
      # weight will be set by caller if provided in attributes
      line_items.create!(jewelry_item_id: jewelry_item.id, price_cents: jewelry_item.price_cents, quantity: quantity)
    end
  end

  # billing helpers
  def subtotal_cents
    line_items.sum('price_cents * quantity')
  end

  def subtotal
    subtotal_cents.to_f / 100.0
  end

  def discount_cents
    (discount.to_f * 100).to_i
  end

  def charges_cents
    (charges.to_f * 100).to_i
  end

  def taxable_amount_cents
    subtotal_cents - discount_cents + charges_cents
  end

  # compute tax amounts (in cents) given a rate percent
  def cgst_amount_cents(rate_percent)
    (taxable_amount_cents * rate_percent / 100.0).to_i
  end

  def igst_amount_cents(rate_percent)
    (taxable_amount_cents * rate_percent / 100.0).to_i
  end

  def total_cents_with_taxes(cgst_rate: 0, igst_rate: 0)
    taxable = taxable_amount_cents
    taxable + cgst_amount_cents(cgst_rate) + igst_amount_cents(igst_rate)
  end

  def total_with_taxes(cgst_rate: 0, igst_rate: 0)
    total_cents_with_taxes(cgst_rate: cgst_rate, igst_rate: igst_rate).to_f / 100.0
  end

  # Computed totals derived from LineItem#line_amount (per-gram * net_weight * qty + making)
  def computed_total_cents
    line_items.sum { |li| li.line_amount_cents }
  end

  def computed_total
    computed_total_cents.to_f / 100.0
  end

  private

  def set_invoice_and_date
  self.sale_date ||= Time.zone.today
    today_invoices_count = Order.where(sale_date: self.sale_date).count + 1
    self.invoice_number ||= "INV-#{self.sale_date.strftime('%Y%m%d')}-#{today_invoices_count.to_s.rjust(3, '0')}"
  end

  def decrement_inventory_on_payment
  Rails.logger.warn "Order##{id} after_update fired (status=#{status.inspect}) previous_changes=#{previous_changes.inspect}"
  # if the order is in paid state and we haven't decremented stock for it yet, proceed
  return unless status == 'paid'
  return if self.respond_to?(:stock_decremented_at) && self.stock_decremented_at.present?

  Rails.logger.warn "Order##{id} status is paid and stock not yet decremented - processing #{line_items.count} line_items"

    Order.transaction do
      line_items.each do |li|
        ji = li.jewelry_item
        unless ji
          Rails.logger.warn "Order##{id} line_item #{li.id} has no associated jewelry_item"
          next
        end

        qty_to_subtract = li.quantity.to_i
        # log current quantity
  Rails.logger.warn "JewelryItem##{ji.id} current quantity=#{ji.quantity.inspect}, subtract=#{qty_to_subtract}"

        # Use an atomic SQL update to avoid race conditions and prevent negative quantities.
        # SQLite does not have GREATEST(), so use a CASE expression which works across adapters.
        JewelryItem.where(id: ji.id).update_all(["quantity = CASE WHEN quantity - ? < 0 THEN 0 ELSE quantity - ? END", qty_to_subtract, qty_to_subtract])

        # reload and log the new quantity for visibility
        ji.reload
        Rails.logger.warn "JewelryItem##{ji.id} new quantity=#{ji.quantity.inspect}"
      end

      # mark that we've decremented stock to make operation idempotent
        if self.respond_to?(:stock_decremented_at)
        update_column(:stock_decremented_at, Time.zone.now)
      end
    end
  end
end
