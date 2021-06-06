class TruckInfo < ApplicationRecord
  belongs_to :truck

  has_many_attached :images
end
