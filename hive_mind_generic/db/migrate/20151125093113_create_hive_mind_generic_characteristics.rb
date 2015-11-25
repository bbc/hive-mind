class CreateHiveMindGenericCharacteristics < ActiveRecord::Migration
  def change
    create_table :hive_mind_generic_characteristics do |t|
      t.string :key
      t.string :value
      t.integer :plugin_id

      t.timestamps null: false
    end
  end
end
