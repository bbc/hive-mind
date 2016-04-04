json.array!(@devices) do |device|
  json.extract! device, :id, :name, :serial, :asset_id, :alternative, :model_id
  json.url device_url(device, format: :json)

  json.action @device_actions[device.id]

  if not (device.device_type.nil? or local_assigns.has_key? :no_cascade)
    @device = device
    render_partial_if_exists json, "shared/#{@device.device_type.downcase}_plugin_partial"
  end
end
