class CreateIps < ActiveRecord::Migration
  def change
    create_table :ips do |t|
      t.integer :device_id
      t.string :ip

      t.timestamps null: false
    end
  end
end
