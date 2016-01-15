json.extract! @device, :id, :name, :serial, :asset_id, :alternative, :model_id, :created_at, :updated_at, :plugin
json.extract! @device.plugin, *@device.plugin_json_keys
