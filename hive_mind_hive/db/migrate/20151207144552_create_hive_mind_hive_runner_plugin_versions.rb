class CreateHiveMindHiveRunnerPluginVersions < ActiveRecord::Migration
  def change
    create_table :hive_mind_hive_runner_plugin_versions do |t|
      t.string :name
      t.string :version

      t.timestamps null: false
    end
  end
end
