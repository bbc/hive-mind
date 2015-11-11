class AddDeviceDataToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :device_type, :string
    add_column :devices, :device_data_id, :integer
  end
end
