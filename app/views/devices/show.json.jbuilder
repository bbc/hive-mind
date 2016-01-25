json.extract! @device, :id, :name, :serial, :asset_id, :alternative, :model_id, :created_at, :updated_at
json.partial! partial: 'devices/show', locals: { device: @device, device_action: @device_action }
