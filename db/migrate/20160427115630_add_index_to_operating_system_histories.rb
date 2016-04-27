class AddIndexToOperatingSystemHistories < ActiveRecord::Migration
  def change
    add_index :operating_system_histories, :device_id
  end
end
