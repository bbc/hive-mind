class HeartbeatIndex < ActiveRecord::Migration
  def change
    add_index :device_actions, [ :device_id, :executed_at ]
  end
end
