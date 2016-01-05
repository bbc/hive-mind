class CreateDeviceActions < ActiveRecord::Migration
  def change
    create_table :device_actions do |t|
      t.integer :device_id
      t.string :action_type
      t.string :body
      t.datetime :executed_at

      t.timestamps null: false
    end
  end
end
