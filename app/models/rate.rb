class Rate < ActiveRecord::Base
  validates :date, presence: true
  validates :metal_type, presence: true
  validates :price_cents_per_gram, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def price_per_gram
    price_cents_per_gram.to_f / 100.0
  end
end
