class AddUnitToDeviceStatistics < ActiveRecord::Migration
  def change
    add_column :device_statistics, :unit, :string
  end
end
