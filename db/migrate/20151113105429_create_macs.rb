class CreateMacs < ActiveRecord::Migration
  def change
    create_table :macs do |t|
      t.integer :device_id
      t.string :mac

      t.timestamps null: false
    end
  end
end
