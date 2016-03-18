class Api::DevicesController < ApplicationController
  # This turns off CSRF verification for the API
  # TODO Provide other methods of authentication
  skip_before_action :verify_authenticity_token

  # POST /register
  def register
    status = :created
    create_parameters = device_params

    if create_parameters[:ips]
      create_parameters[:ips] = create_parameters[:ips].map do |i|
        mac = Ip.find_or_create_by(ip: i)
      end
    end

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
    if device_id and @device = Device.find_by(id: device_id)
      status = :accepted
      @device.update(create_parameters)
      @device.set_os(
        name: params[:device][:operating_system_name],
        version: params[:device][:operating_system_version]
      ) if params[:device].has_key?(:operating_system_name) || params[:device].has_key?(:operating_system_version)
      if @device.plugin
        filtered_params = params[:device].clone
        filtered_params.delete(:id)
        filtered_params[:id] = filtered_params[:plugin_id] if filtered_params.has_key?(:plugin_id)
        obj = @device.plugin.class
        @device.plugin.update(obj.plugin_params(filtered_params))
      end
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
          logger.debug "Unknown device type"
        end
      end

      if create_parameters.length > 0
        @device= Device.create(create_parameters)
        @device.set_os(
          name: params[:device][:operating_system_name],
          version: params[:device][:operating_system_version]
        )
      else
        status = params['device'].key?('id') ? :not_found : :unprocessable_entity
      end
    end

    if [:accepted, :created].include?(status)
      if @device.save
        @device.heartbeat
        render 'devices/show', status: status
      else
        render json: @device.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Registration failed' }, status: status
    end
  end

  # PUT /poll
  def poll
    begin
      reporting_device = Device.find(params[:poll][:id])
      if params[:poll][:devices].present? and params[:poll][:devices].length > 0
        # Reporting a list of devices
        args = { reported_by: reporting_device }
        @devices = params[:poll][:devices].map { |d| Device.find(d) }
        @devices.each do |d|
          d.heartbeat( reported_by: reporting_device )
        end
        render 'devices/index', status: :ok
      else
        # Reporting a single device
        reporting_device.heartbeat
        @device_action = reporting_device.execute_action
        @device = reporting_device
        render 'devices/show', status: :ok
      end
    rescue ActiveRecord::RecordNotFound
      render json: {}, status: :not_found
    end
  end

  # PUT /action
  def action
    status = :ok
    if ( action = DeviceAction.order(id: :desc).find_by(action_params) ) && action.executed_at == nil
      status = :already_reported
    else
      action = DeviceAction.create(action_params)
    end

    render json: {}, status: status
  end

  # PUT /hive_queues
  def hive_queues
    status = :ok
    device = Device.find(params[:device_id])
    device.hive_queues = params[:hive_queues] ? params[:hive_queues].select { |q| q.to_s != '' }.map { |q| hq = HiveQueue.find_or_create_by(name: q) } : []
    device.save
    render json: {}, status: status
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

    def action_params
      params.require(:device_action).permit(
        :device_id,
        :action_type,
        :body
      )
    end
end
