class CreateDeviceStates < ActiveRecord::Migration
  def change
    create_table :device_states do |t|
      t.references :device, index: true, foreign_key: true
      t.string :component
      t.integer :state, limit: 1, null: false
      t.string :message

      t.timestamps null: false
    end
  end
end
