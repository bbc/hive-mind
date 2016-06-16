class StatisticsPrecision < ActiveRecord::Migration
  def change
    remove_column :device_statistics, :value
    add_column :device_statistics, :value, :decimal, precision: 10, scale: 10
  end
end
