class Store < ActiveRecord::Base
  has_many :metal_stocks, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
