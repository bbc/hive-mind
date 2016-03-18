class ModelsController < ApplicationController
  before_action :set_model, only: [:show, :edit, :update, :destroy]

  # GET /models/1
  # GET /models/1.json
  def show
    @devices = @model.devices
    if params[:group] && params[:group] != ""
      @group = Group.find(params[:group].to_i)
      @devices = @devices.select { |device| device.groups.include?(@group) }
    end
    
    if params[:brand] && params[:brand] != ""
      @brand = Brand.find(params[:brand].to_i)
    end
    
    
    if params[:device_type] && params[:device_type] != ""
      @device_type = DeviceType.find(params[:device_type].to_i)
    end
    
  end

  # GET /models/new
  def new
    @model = Model.new(brand_id: params[:brand], device_type_id: params[:device_type])
  end

  # GET /models/1/edit
  def edit
  end

  # POST /models
  # POST /models.json
  def create
    @model = Model.new(model_params)

    respond_to do |format|
      if @model.save
        format.html { redirect_to @model, notice: 'Model was successfully created.' }
        format.json { render :show, status: :created, location: @model }
      else
        format.html { render :new }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /models/1
  # PATCH/PUT /models/1.json
  def update
    respond_to do |format|
      if @model.update(model_params)
        format.html { redirect_to @model, notice: 'Model was successfully updated.' }
        format.json { render :show, status: :ok, location: @model }
      else
        format.html { render :edit }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /models/1
  # DELETE /models/1.json
  def destroy
    @model.destroy
    respond_to do |format|
      format.html { redirect_to '/browse', notice: 'Model was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_model
      @model = Model.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def model_params
      params.require(:model).permit(:name, :description, :alternative, :brand_id, :device_type_id)
    end
end
