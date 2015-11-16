class RemoveMacAndIpFromHiveMindHiveAttributes < ActiveRecord::Migration
  def change
    remove_column :hive_mind_hive_attributes, :ip, :string
    remove_column :hive_mind_hive_attributes, :mac, :string
  end
end
