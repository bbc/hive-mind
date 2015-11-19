class Api::DevicesController < ApplicationController
  # This turns off CSRF verification for the API
  # TODO Provide other methods of authentication
  skip_before_action :verify_authenticity_token

  # POST /register
  def register
    create_parameters = device_params
    if params[:device].has_key?(:device_type)
      begin
        obj = Object.const_get("HiveMind#{params[:device][:device_type].capitalize}::Plugin")
        create_parameters[:plugin] = obj.find_or_create_by(obj.plugin_params(params[:device]))
        create_parameters[:name] ||= create_parameters[:plugin].name
      rescue NameError
        puts "Unknown device type"
      end
    end

    @device = Device.find_or_create_by(create_parameters)

    if @device.save
      render json: @device, status: :created
    else
      render json: @device.errors, status: :unprocessable_entity
    end
  end

  private
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
