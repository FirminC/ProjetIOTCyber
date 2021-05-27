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

    def new
        @truck = Truck.new
    end
    
    def create
        @truck = Truck.new(truck_params)
        randomhex = SecureRandom.hex(16) #Generate a 32 char long Hex number
        
        while Truck.exists?(hex_identifier: randomhex)
            randomhex = SecureRandom.hex(16) #Generate a 32 char long Hex number
            puts("whileloop")
        end

        @truck.hex_identifier = randomhex
        
        if @truck.save
            redirect_to @truck, notice: "Truck created"
        else
            render :new, status: :unprocessable_entity
        end
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
