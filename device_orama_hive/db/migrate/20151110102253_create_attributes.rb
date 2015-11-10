class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.string :hostname
      t.string :ip
      t.string :mac

      t.timestamps null: false
    end
  end
end
