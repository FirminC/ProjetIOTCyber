require 'rqrcode'

class TrucksController < ApplicationController
    before_action :set_truck, only: [:show, :edit, :update, :destroy]
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

    def update
        #set_truck
        if @truck.update(truck_params)
            redirect_to trucks_path, notice: "Truck updated"
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        #set_truck
        @truck.destroy
    end

    private
    def set_truck
        @truck = Truck.find(params[:id])
    end

    def truck_params
        params.require(:truck).permit(:name, :description)
    end
end
