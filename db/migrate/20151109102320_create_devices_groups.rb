class CreateDevicesGroups < ActiveRecord::Migration
  def change
    create_table :devices_groups do |t|
      t.integer :device_id
      t.integer :group_id
    end
  end
end
