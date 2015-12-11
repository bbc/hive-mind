require 'timecop'

DeviceType.find_or_create_by(classification: 'TV')
DeviceType.find_or_create_by(classification: 'Hive')

## Add in iOS devices
brand = Brand.first_or_create(name: 'Apple')
device_type = DeviceType.find_or_create_by(classification: 'Mobile')

devices = YAML.load_file("#{pwd}/db/apple.yml")

def self.register_devices(device_type, brand, devices)
  devices.each do |device_name, values|
    Model.find_or_create_by(device_type: device_type, brand: brand, name: device_name )
    values.each do |variant, variant_values|
      Group.find_or_create_by(name: 'Variant', value: variant, description: variant_values['description'])
      variant_values["models"].each do |models, model_description|
        models.split(',').each do |model|
          Group.find_or_create_by(name: 'Product Model', value: model, description: model_description)
        end
      end
    end
  end
end

register_devices(device_type, brand, devices)

# Add a couple of iPad 4s
d1 = Device.find_or_create_by(model: Model.where(name: 'iPad Mini 4').first, name: 'iPad Mini 4', serial: 'abcdefghij', asset_id: '12345') { |a| a.groups = [Group.where(value: 'A1550').first, Group.where(value: 'MK892').first] }
d2 = Device.find_or_create_by(model: Model.where(name: 'iPad Mini 4').first, name: 'iPad Mini 4(ii)', serial: 'abcdefghik', asset_id: '54321') { |a| a.groups = [Group.where(value: 'A1538').first, Group.where(value: 'MK9N2').first] }

# And a iPad 2
d3 = Device.find_or_create_by(model: Model.where(name: 'iPad 2').first, name: 'iPad 2', serial: 'zyxwvutsr', asset_id: '11111') { |a| a.groups = [Group.where(value: 'A1396').first, Group.where(value: 'MC984').first] }

# Some heartbeats
[120, 90, 60, 30, 0].each do |t|
  Timecop.freeze(Time.now - t) do
    d1.heartbeat
  end
end
[101, 3].each do |t|
  Timecop.freeze(Time.now - t) do
    d2.heartbeat
  end
end
[999].each do |t|
  Timecop.freeze(Time.now - t) do
    d3.heartbeat
  end
end
