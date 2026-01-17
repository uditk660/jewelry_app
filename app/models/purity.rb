class Purity < ActiveRecord::Base
  belongs_to :metal
  validates :purity_percent, numericality: true, allow_nil: true
  validates :name, presence: true
end
