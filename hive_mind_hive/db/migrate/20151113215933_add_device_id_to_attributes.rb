class AddDeviceIdToAttributes < ActiveRecord::Migration
  def change
    add_column :hive_mind_hive_attributes, :device_id, :integer
  end
end
