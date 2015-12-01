class CreateHiveMindHiveRunnerVersions < ActiveRecord::Migration
  def change
    create_table :hive_mind_hive_runner_versions do |t|
      t.string :version

      t.timestamps null: false
    end
  end
end
