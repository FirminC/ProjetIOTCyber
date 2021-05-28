class Truck < ApplicationRecord
    has_many :truck_infos, dependent: :destroy

    def lastTruckMapInfo
        truck_infos.select(:lat, :lon, :fuel_level, :is_stolen, :created_at).last
    end
end
