require 'rqrcode'

class TrucksController < ApplicationController
    skip_before_action :authorized, only: [:addTruckInfo]
    skip_before_action :verify_authenticity_token, only: [:addTruckInfo]
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
            standalone: true,
            viewbox: true
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
        json = @truck.as_json(only: [:hex_identifier]);
        json["delete"] = true
        @truck.destroy
        ActionCable.server.broadcast('messages_channel', message: json.to_json())
        redirect_to trucks_path, notice: "Truck was succesfully destroyed"
    end

    def addTruckInfo
        if request.get?
            render :json => {:description => "API endpoint to add data from trucks"}
        else 
            if truck_infos_params[:hex_identifier]
                if truck = Truck.find_by(hex_identifier: truck_infos_params[:hex_identifier])
                    if truck.truck_infos.create(truck_infos_params.permit(:is_stolen, :fuel_level, :lat, :lon, images: []))
                        json = truck.to_json(only: [:id, :hex_identifier, :name], methods: :lastTruckMapInfo)
                        ActionCable.server.broadcast('messages_channel', message: json)
                        render :json => {:status => "Created"}
                    else
                        render :json => {:status => "Internal server Error"}, status: :internal_server_error
                    end
                else
                    render :json => {:status => "Identifier not recognized"}, status: :bad_request
                end
            else
                render :json => {:status => "Not authorized"}, status: :unauthorized
            end
        end
    end

    def truckInfoImages
        @truck = Truck.find(params[:truck_id])
        @truckinfoimages = @truck.truck_infos.find(params[:id]).images
    end

    private
    def set_truck
        @truck = Truck.find(params[:id])
    end

    def truck_params
        params.require(:truck).permit(:name, :description)
    end

    def truck_infos_params
        params.permit(:hex_identifier, :is_stolen, :fuel_level, :lat, :lon, images: [])
    end
end
