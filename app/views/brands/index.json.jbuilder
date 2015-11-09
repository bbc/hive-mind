json.array!(@brands) do |brand|
  json.extract! brand, :id, :name, :code, :alternative
  json.url brand_url(brand, format: :json)
end
