json.extract! device, :id, :name, :serial, :asset_id, :alternative, :model_id, :created_at, :updated_at

json.model device.model.name
json.brand device.model.brand.name

if local_assigns.has_key? :device_action
  json.action device_action
end

if not local_assigns.has_key? :no_cascade
  render_partial_if_exists json, "shared/#{device.device_type.downcase}_plugin_partial"
end
