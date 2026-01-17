class Customer < ActiveRecord::Base
  has_many :orders

  validates :phone, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true

  # Return a display-friendly full name for the customer
  def full_name
    [first_name, last_name].compact.join(' ').strip
  end
end
