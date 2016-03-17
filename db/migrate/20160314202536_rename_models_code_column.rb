class RenameModelsCodeColumn < ActiveRecord::Migration
  def change
    rename_column :models, :code, :display_name
  end
end
