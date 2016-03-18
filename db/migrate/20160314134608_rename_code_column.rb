class RenameCodeColumn < ActiveRecord::Migration
  def change
    rename_column :brands, :code, :display_name
  end
end
