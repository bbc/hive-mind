class CreateHiveMindHiveAttributes < ActiveRecord::Migration
  def change
    create_table :hive_mind_hive_attributes do |t|
      t.string :hostname
      t.string :ip
      t.string :mac

      t.timestamps null: false
    end
  end
end
