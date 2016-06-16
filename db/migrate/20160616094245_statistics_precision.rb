class StatisticsPrecision < ActiveRecord::Migration
  def change
    change_column :device_statistics, :value, :decimal, precision: 16, scale: 8
  end
end
