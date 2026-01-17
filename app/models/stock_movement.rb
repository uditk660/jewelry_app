class StockMovement < ActiveRecord::Base
  belongs_to :inventory_item
  validates :change_grams, numericality: { only_integer: true }
  validates :movement_type, presence: true
end
