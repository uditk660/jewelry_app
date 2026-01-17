class Metal < ActiveRecord::Base
  has_many :purities, dependent: :destroy
  has_many :jewellery_categories, dependent: :destroy
  # association to catalog items (British-english "jewellery" models use jewellery_category but items are named JewelryItem)
  has_many :jewelry_items, class_name: 'JewelryItem', foreign_key: 'metal_id', dependent: :nullify
  has_many :metal_stocks, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
