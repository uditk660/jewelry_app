class Metal < ActiveRecord::Base
  has_many :purities, dependent: :destroy
  has_many :jewellery_categories, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
