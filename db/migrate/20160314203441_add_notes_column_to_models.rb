class AddNotesColumnToModels < ActiveRecord::Migration
  def change
    add_column :models, :description, :text
  end
end
