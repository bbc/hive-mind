class AddDeviceIdIndexToHeartbeat < ActiveRecord::Migration
  def change
    add_index :heartbeats, :device_id
  end
end
