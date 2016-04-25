@devices.keys.each do |type|
  json.array!(@devices[type]) do |device|
    json.extract! device, :id, :name, :serial, :asset_id, :alternative, :model_id, :plugin_type
    json.url device_url(device, format: :json)

    if @device_actions
      json.action @device_actions[device.id]
    end

    if not (device.device_type.nil? or local_assigns.has_key? :no_cascade)
      @device = device
      render_partial_if_exists json, "shared/#{@device.device_type.downcase}_plugin_partial"
    end
  end
end
