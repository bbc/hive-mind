class AddPluginIdToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :plugin_id, :integer
    add_column :devices, :plugin_type, :string
  end
end
