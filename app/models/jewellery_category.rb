class JewelleryCategory < ActiveRecord::Base
  belongs_to :metal
  validates :name, presence: true
end
