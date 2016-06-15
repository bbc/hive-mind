class CreateDeviceStatistics < ActiveRecord::Migration
  def change
    create_table :device_statistics do |t|
      t.integer :device_id
      t.datetime :timestamp
      t.string :label
      t.decimal :value
      t.string :format

      t.timestamps null: false
    end
    add_index :device_statistics, :device_id
    add_index :device_statistics, [:device_id, :label]
  end
end
