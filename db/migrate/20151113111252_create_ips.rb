class CreateIps < ActiveRecord::Migration
  def change
    create_table :ips do |t|
      t.string :ip
      t.string :device_id

      t.timestamps null: false
    end

    add_column :devices, :ip_id, :string
  end
end
