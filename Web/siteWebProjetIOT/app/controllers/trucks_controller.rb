require 'rqrcode'

class TrucksController < ApplicationController
    before_action :set_truck, only: [:show, :edit]
    before_action :admin_authorized, only: [:edit, :update, :destory]

    def index
        @trucks = Truck.all
    end

    def show
        #set_truck
        @truckInfos = @truck.truck_infos.order(created_at: :desc)
        @qr = RQRCode::QRCode.new(@truck.hex_identifier).as_svg(
            offset: 0,
            color: '000',
            shape_rendering: 'crispEdges',
            module_size: 6,
            standalone: true
        )
    end

    def edit
        #set_truck
    end

    private
    def set_truck
        @truck = Truck.find(params[:id])
    end
end
