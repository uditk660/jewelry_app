class InventoryItem < ActiveRecord::Base
  belongs_to :jewelry_item
  has_many :stock_movements, dependent: :restrict_with_error

  validates :available_grams, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def adjust!(change_grams, movement_type: 'adjustment', note: nil)
    transaction do
      self.available_grams += change_grams
      save!
      stock_movements.create!(change_grams: change_grams, movement_type: movement_type, note: note)
    end
  end
end
