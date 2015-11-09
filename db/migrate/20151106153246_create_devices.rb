class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name
      t.string :serial
      t.string :asset_id
      t.string :alternative
      t.references :model, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
