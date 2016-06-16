class StatisticsPrecision < ActiveRecord::Migration
  def change
    change_column :device_statistics, :value, :decimal, precision: 10, scale: 10
  end
end
