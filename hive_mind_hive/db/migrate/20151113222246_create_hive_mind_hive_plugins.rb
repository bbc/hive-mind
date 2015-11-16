class CreateHiveMindHivePlugins < ActiveRecord::Migration
  def change
    create_table :hive_mind_hive_plugins do |t|
      t.string :hostname
      t.integer :device_id

      t.timestamps null: false
    end
  end
end
