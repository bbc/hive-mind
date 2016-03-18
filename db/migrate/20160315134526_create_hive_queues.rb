class CreateHiveQueues < ActiveRecord::Migration
  def change
    create_table :hive_queues do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end

    create_table :devices_hive_queues, id: false do |t|
      t.belongs_to :device, index: true
      t.belongs_to :hive_queue, index: true
    end
  end
end
