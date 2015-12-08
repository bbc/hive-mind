class CreateHiveMindHiveRunnerPluginVersionHistories < ActiveRecord::Migration
  def change
    create_table :hive_mind_hive_runner_plugin_version_histories do |t|
      t.integer :plugin_id
      t.integer :runner_plugin_version_id
      t.datetime :start_timestamp
      t.datetime :end_timestamp

      t.timestamps null: false
    end
  end
end
