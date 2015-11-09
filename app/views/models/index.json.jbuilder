json.array!(@models) do |model|
  json.extract! model, :id, :name, :code, :alternative, :brand_id
  json.url model_url(model, format: :json)
end
