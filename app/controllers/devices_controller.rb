class DevicesController < ApplicationController
  before_action :set_device, only: [:edit, :update, :destroy]

  # GET /devices
  # GET /devices.json
  def index
    @devices = Device.includes(:ips, :macs, :brand, :plugin, :model => [:device_type] ).all.group_by { |d| d.model && d.model.device_type }
  end
  
  def dash
    ids = params[:ids].split(',').collect { |id| id.to_i }
    @devices = Device.includes(:ips, :macs, :brand, :plugin, :model => [:device_type] ).where( id: ids )
  end
  
  def search
    @search_string = params[:search_string]
    @devices = Device.search(name_or_serial_or_model_name_cont: @search_string).result.distinct(:true)
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
    respond_to do |format|
      format.html do
        @device = Device.includes(:ips, :macs, :model, :brand, :plugin, :hive_queues, :related_devices => [ :ips, :macs, :model, :brand, :plugin, :hive_queues ]).find(params['id'])
      end
      format.json do
        if params[:view].present? && params[:view] == 'simple'
          device = Device.includes(:model, :brand).find(params['id'])
          @device = {
            id: device.id,
            name: device.name,
            model: device.model ? device.model.name : nil,
            brand: device.model && device.model.brand ? device.model.brand.name : nil,
            device_type: device.device_type
          }
          render json: @device
        else
          @device = Device.includes(:ips, :macs, :model, :brand, :plugin, :hive_queues, :related_devices => [ :ips, :macs, :model, :brand, :plugin, :hive_queues ]).find(params['id'])
        end
      end
    end
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(device_params)

    respond_to do |format|
      if @device.save
        format.html { redirect_to device_url(@device, protocol: redirect_protocol), notice: 'Device was successfully created.' }
        format.json { render :show, status: :created, location: @device }
      else
        format.html { render :new }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to device_url(@device, protocol: redirect_protocol), notice: 'Device was successfully updated.' }
        format.json { render :show, status: :ok, location: @device }
      else
        format.html { render :edit }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device.destroy
    respond_to do |format|
      format.html { redirect_to devices_url(protocol: redirect_protocol), notice: 'Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(
        :name,
        :serial,
        :asset_id,
        :alternative,
        :model_id,
        { group_ids: [] },
        macs: [],
        ips: [],
      )
    end
end
