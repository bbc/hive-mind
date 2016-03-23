class DeviceTypesController < ApplicationController
  before_action :set_device_type, only: [:show, :edit, :update, :destroy]

  # GET /browse
  def browse
    @device_types = DeviceType.all
  end

  # GET /device_types/new
  def new
    @device_type = DeviceType.new
  end

  # GET /device_types/1/edit
  def edit
  end

  # POST /device_types
  # POST /device_types.json
  def create
    @device_type = DeviceType.new(device_type_params)

    respond_to do |format|
      if @device_type.save
        format.html { redirect_to '/browse', notice: 'Device type was successfully created.', protocol: redirect_protocol }
        format.json { render :show, status: :created, location: @device_type }
      else
        format.html { render :new }
        format.json { render json: @device_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /device_types/1
  # PATCH/PUT /device_types/1.json
  def update
    respond_to do |format|
      if @device_type.update(device_type_params)
        format.html { redirect_to '/browse', notice: 'Device type was successfully updated.', protocol: redirect_protocol }
        format.json { render :show, status: :ok, location: @device_type }
      else
        format.html { render :edit }
        format.json { render json: @device_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /device_types/1
  # DELETE /device_types/1.json
  def destroy
    @device_type.destroy
    respond_to do |format|
      format.html { redirect_to device_types_url, notice: 'Device type was successfully destroyed.', protocol: redirect_protocol }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device_type
      @device_type = DeviceType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_type_params
      params.require(:device_type).permit(:classification, :description)
    end
end
