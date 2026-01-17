class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :jewelry_item

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :weight, numericality: { greater_than: 0 }
  validates :gross_weight, numericality: { greater_than_or_equal_to: 0 }
  validates :net_weight, numericality: { greater_than_or_equal_to: 0 }
  validates :making_charge, numericality: { greater_than_or_equal_to: 0 }

  def total_cents
  # include making charge per-line (converted to cents)
  (price_cents * quantity) + (making_charge.to_f * 100).to_i
  end

  def total
    total_cents.to_f / 100.0
  end
end
