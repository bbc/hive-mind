class AddTimestampToDeviceStatisticsIndex < ActiveRecord::Migration
  def change
    remove_index :device_statistics, [ :device_id, :label ]
    add_index :device_statistics, [ :device_id, :label, :timestamp ]
  end
end
