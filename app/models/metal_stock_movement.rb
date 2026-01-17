class MetalStockMovement < ActiveRecord::Base
  belongs_to :metal_stock
  validates :change_grams, numericality: { only_integer: true }
  validates :movement_type, presence: true
end
