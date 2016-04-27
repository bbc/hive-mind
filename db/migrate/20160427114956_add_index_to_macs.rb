class AddIndexToMacs < ActiveRecord::Migration
  def change
    add_index :macs, :device_id
  end
end
