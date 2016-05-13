class CreateHiveMindMobilePlugins < ActiveRecord::Migration
  def change
    create_table :hive_mind_mobile_plugins do |t|
      t.integer :device_id
      t.string :imei
      t.string :serial

      t.timestamps null: false
    end
  end
end
