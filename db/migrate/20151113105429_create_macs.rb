class CreateMacs < ActiveRecord::Migration
  def change
    create_table :macs do |t|
      t.string :mac
      t.integer :device_id

      t.timestamps null: false
    end

    add_column :devices, :mac_id, :string
  end
end
