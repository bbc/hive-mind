class AddPluginIdToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :plugin_id, :integer
    add_column :devices, :plugin_type, :string
    remove_column :devices, :device_type, :string
    remove_column :devices, :device_data_id, :integer
  end
end
