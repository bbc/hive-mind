json.array!(@devices) do |device|
  json.extract! device, :id, :name, :serial, :asset_id, :alternative, :model_id
  json.url device_url(device, format: :json)
end
