json.array!(@devices) do |device|
  json.extract! device, :id, :name
  json.url device_url(device, format: :json)
end
