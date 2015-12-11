class CreateHeartbeats < ActiveRecord::Migration
  def change
    create_table :heartbeats do |t|
      t.integer :device_id
      t.integer :reporting_device_id
      t.datetime :created_at, nil: false
    end
  end
end
