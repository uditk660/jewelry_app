class Payment < ActiveRecord::Base
  belongs_to :order
  belongs_to :customer, optional: true

  validates :amount_cents, numericality: { greater_than: 0 }
end
