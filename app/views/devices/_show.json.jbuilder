json.extract! device, :id, :name, :serial, :asset_id, :alternative, :model_id, :created_at, :updated_at, :device_type, :hive_queues, :status

if device.model
  json.model device.model.name
  json.brand device.model.brand.name if device.model.brand
end

if device.operating_system
  json.operating_system_name device.operating_system.name
  json.operating_system_version device.operating_system.version
end

if local_assigns.has_key? :device_action
  json.action device_action
end

if not (device.device_type.nil? or local_assigns.has_key? :no_cascade)
  render_partial_if_exists json, "shared/#{device.device_type.downcase}_plugin_partial"
end
