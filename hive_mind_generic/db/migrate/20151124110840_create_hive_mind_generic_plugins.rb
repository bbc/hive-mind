class CreateHiveMindGenericPlugins < ActiveRecord::Migration
  def change
    create_table :hive_mind_generic_plugins do |t|

      t.timestamps null: false
    end
  end
end
