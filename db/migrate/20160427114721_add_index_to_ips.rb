class AddIndexToIps < ActiveRecord::Migration
  def change
    add_index :ips, :device_id
  end
end
