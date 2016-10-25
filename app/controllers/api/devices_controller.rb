class Api::DevicesController < ApplicationController
  # This turns off CSRF verification for the API
  # TODO Provide other methods of authentication
  skip_before_action :verify_authenticity_token

  # POST /register
  def register
    status = :created

    filtered_params = params[:device].clone
    aux_params = auxiliary_device_params
    create_parameters = device_params

    if create_parameters[:ips]
      create_parameters[:ips] = create_parameters[:ips].compact.map do |i|
        mac = Ip.find_or_create_by(ip: i)
      end
    end

    # Find device if it already exists
    if create_parameters[:macs]
      create_parameters[:macs] = create_parameters[:macs].compact.map do |m|
        mac = Mac.find_or_create_by(mac: m)
      end
    end
    @device = Device.identify_existing(filtered_params.merge(create_parameters))
    device_id = @device ? @device.id : nil

    device_type = aux_params[:device_type] || 'unknown'
    if aux_params[:brand] and aux_params[:model]
      create_parameters[:model] = Model.find_or_create_by(
        name: aux_params[:model],
        brand: Brand.find_or_create_by(name: aux_params[:brand]),
        device_type: DeviceType.find_or_create_by(classification: device_type),
      )
    end

    device_id ||= params['device']['id']
    if device_id and @device = Device.find_by(id: device_id)
      status = :accepted
      @device.update(create_parameters)
      @device.set_os(
        name: aux_params[:operating_system_name],
        version: aux_params[:operating_system_version]
      ) if aux_params.has_key?(:operating_system_name) || aux_params.has_key?(:operating_system_version)
      if @device.plugin
        filtered_params.delete(:id)
        filtered_params[:id] = filtered_params[:plugin_id] if filtered_params.has_key?(:plugin_id)
        obj = @device.plugin.class
        @device.plugin.update(obj.plugin_params(filtered_params))
      end
    else
      if aux_params.has_key?(:device_type)
        begin
          obj = Object.const_get("HiveMind#{aux_params[:device_type].capitalize}::Plugin")
          # Filter parameters for plugin
          #   id removed (this is the id in Device)
          #   plugin_id -> id
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
          name: aux_params[:operating_system_name],
          version: aux_params[:operating_system_version]
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
    poll_type = params[:poll][:poll_type] || 'active'
    begin
      reporting_device = Device.includes(:model, :brand).find(params[:poll][:id])
      if params[:poll][:devices].present? and params[:poll][:devices].length > 0
        # Reporting a list of devices
        @device_actions = {}
        @devices = Device.includes(:ips, :macs, :brand, :plugin, :model => [:device_type] ).where( id: params[:poll][:devices] ).group_by { |d| d.model && d.model.device_type }
        @devices.collect{|_,v| v }.flatten.each do |d|
          @device_actions[d.id] = poll_device d, reported_by: reporting_device, poll_type: poll_type
        end
        render 'devices/index', status: :ok
      else
        # Reporting a single device
        @device_action = poll_device reporting_device, poll_type: poll_type
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
      status = DeviceAction.create(action_params).valid? ? :ok : :unprocessable_entity
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

  def screenshot
    device = Device.find(params[:device_action][:device_id])
    render json: {}, status: :unprocessable_entity unless ( device.plugin && device.plugin.methods.include?(:screenshot))
    status = :ok
    device.plugin.screenshot = "data:image/png;base64, #{params[:device_action][:screenshot]}"
    device.plugin.save

    render json: {}, status: status
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.fetch(:device).permit(
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

    def filter_device_params
      filtered_params = {}
      [
        :name,
        :serial,
        :asset_id,
        :alternative,
        :model_id,
        macs: [],
        ips: [],
      ].each do |k|
        filtered_params[k] = params[k] if params.has_key? k
      end
    end

    # Parameters for registration that are not part of the white list
    def auxiliary_device_params
      extra_params = {}
      [
          :brand,
          :device_type,
          :model,
          :operating_system_name,
          :operating_system_version,
      ].each do |p|
        extra_params[p] = params[:device].delete(p) if params[:device].has_key? p
      end
      extra_params
    end

    def action_params
      params.require(:device_action).permit(
        :device_id,
        :action_type,
        :body,
        :screenshot
      )
    end

    def poll_device d, options = {}
      opts = {}
      opts[:reported_by] = options[:reported_by] if options.has_key? :reported_by
      d.heartbeat opts
      options[:poll_type] == 'active' ? d.execute_action : nil
    end
end
