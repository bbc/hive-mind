class CreateOperatingSystemHistories < ActiveRecord::Migration
  def change
    create_table :operating_system_histories do |t|
      t.integer :device_id
      t.integer :operating_system_id
      t.datetime :start_timestamp
      t.datetime :end_timestamp

      t.timestamps null: false
    end
  end
end
