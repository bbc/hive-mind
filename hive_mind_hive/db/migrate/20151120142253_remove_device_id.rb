class RemoveDeviceId < ActiveRecord::Migration
  def change
    remove_column :hive_mind_hive_plugins, :device_id, :integer
  end
end
