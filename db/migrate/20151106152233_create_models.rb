class CreateModels < ActiveRecord::Migration
  def change
    create_table :models do |t|
      t.string :name
      t.string :code
      t.string :alternative
      t.references :brand, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
