class Truck < ApplicationRecord
    has_many :truck_infos, dependent: :destroy
end
