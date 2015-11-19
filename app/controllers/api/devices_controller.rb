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
    create_parameters[:ips] ||= []
    create_parameters[:ips] = create_parameters[:ips].map{|i| Ip.find_or_create_by(ip: i)}

    # Uniquely identify by (first) MAC address
    device_id = nil
    if create_parameters[:macs]
      create_parameters[:macs] = create_parameters[:macs].map do |m|
        mac = Mac.find_or_create_by(mac: m)
        device_id ||= mac.device_id
        mac
      end
    end

    device_type = params[:device][:device_type] || 'unknown'
    if params[:device][:brand] and params[:device][:model]
      create_parameters[:model] = Model.find_or_create_by(
        name: params[:device][:model],
        brand: Brand.find_or_create_by(name: params[:device][:brand]),
        device_type: DeviceType.find_or_create_by(classification: device_type),
      )
    end

    device_id ||= params['device']['id']
    if device_id and @device = Device.find(device_id)
      @device.update(create_parameters)
    else
      @device= Device.create(create_parameters)
    end

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
