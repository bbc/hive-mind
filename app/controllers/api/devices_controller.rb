class Api::DevicesController < ApplicationController
  # This turns off CSRF verification for the API
  # TODO Provide other methods of authentication
  skip_before_action :verify_authenticity_token

  # POST /register
  def register
    create_parameters = device_params

    create_parameters[:ips] ||= []
    create_parameters[:ips] = create_parameters[:ips].map{|i| Ip.find_or_create_by(ip: i)}

    # Find device if it already exists
    if create_parameters[:macs]
      create_parameters[:macs] = create_parameters[:macs].map do |m|
        mac = Mac.find_or_create_by(mac: m)
      end
    end
    @device = Device.identify_existing(params[:device].merge(create_parameters))
    device_id = @device ? @device.id : nil

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
      if params[:device].has_key?(:device_type)
        begin
          obj = Object.const_get("HiveMind#{params[:device][:device_type].capitalize}::Plugin")
          # Filter parameters for plugin
          #   id removed (this is the id in Device)
          #   plugin_id -> id
          filtered_params = params[:device].clone
          filtered_params.delete(:id)
          filtered_params[:id] = filtered_params[:plugin_id] if filtered_params.has_key?(:plugin_id)

          create_parameters[:plugin] = obj.create(obj.plugin_params(filtered_params))
          create_parameters[:name] ||= create_parameters[:plugin].name
        rescue NameError
          puts "Unknown device type"
        end
      end
      @device= Device.create(create_parameters)
    end

    if @device.save
      @device.heartbeat
      render json: @device, status: :created
    else
      render json: @device.errors, status: :unprocessable_entity
    end
  end

  # PUT /poll
  def poll
    @response = {}
    begin
      reporting_device = Device.find(params[:poll][:id])
      if params[:poll][:devices].present? and params[:poll][:devices].length > 0
        args = { reported_by: reporting_device }
        params[:poll][:devices].each do |d|
          Device.find(d).heartbeat( reported_by: reporting_device )
        end
      else
        reporting_device.heartbeat
      end
      render json: @response, status: :success
    rescue ActiveRecord::RecordNotFound
      render json: {}, status: :not_found
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
