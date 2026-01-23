class Customer < ActiveRecord::Base
  has_many :orders
  has_many :payments

  validates :phone, presence: true, uniqueness: true
  validates :first_name, presence: true

  # Return a display-friendly full name for the customer
  def full_name
    [first_name, last_name].compact.join(' ').strip
  end

  # Recompute and persist customer's outstanding balance (sum of remaining across unpaid orders)
  def recompute_balance!
    total_outstanding = orders.where.not(status: 'paid').to_a.sum do |o|
      o.remaining_cents
    end
    update_column(:balance_cents, total_outstanding.to_i)
  end
end
