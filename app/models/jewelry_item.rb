class JewelryItem < ActiveRecord::Base
  validates :name, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :weight_grams, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  belongs_to :metal, optional: true
  belongs_to :purity, optional: true
  belongs_to :jewellery_category, optional: true

  before_validation :set_sku, on: :create

  scope :available_for_sale, -> { where('quantity > 0') }

  def set_sku
    return if sku.present?
    # generate an 11-character SKU: 'J' + 10 alphanumeric chars
    10.times do
      candidate = "J#{SecureRandom.alphanumeric(10).upcase}"
      unless self.class.exists?(sku: candidate)
        self.sku = candidate
        break
      end
    end
    # fallback deterministic-ish SKU (should be rare)
    self.sku ||= "J#{SecureRandom.alphanumeric(10).upcase}"
  end

  def price
    price_cents.to_f / 100.0
  end

  def price=(dollars)
    self.price_cents = (dollars.to_f * 100).round
  end
end
