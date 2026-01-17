class MetalStock < ActiveRecord::Base
  belongs_to :metal
  belongs_to :store
  has_many :metal_stock_movements, dependent: :restrict_with_error

  validates :available_grams, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price_cents_per_gram, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def price_per_gram
    price_cents_per_gram.to_f / 100.0
  end

  def price_per_gram=(dollars)
    self.price_cents_per_gram = (dollars.to_f * 100).round
  end

  def adjust!(change_grams, movement_type: 'adjustment', note: nil)
    transaction do
      self.available_grams += change_grams
      save!
      metal_stock_movements.create!(change_grams: change_grams, movement_type: movement_type, note: note)
    end
  end
end
