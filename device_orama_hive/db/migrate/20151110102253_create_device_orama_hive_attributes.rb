class CreateDeviceOramaHiveAttributes < ActiveRecord::Migration
  def change
    create_table :device_orama_hive_attributes do |t|
      t.string :hostname
      t.string :ip
      t.string :mac

      t.timestamps null: false
    end
  end
end
