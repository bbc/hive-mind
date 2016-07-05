class RemoveDeviceIdIndexOnDeviceStatistics < ActiveRecord::Migration
  def change
    remove_index :device_statistics, :device_id
  end
end
