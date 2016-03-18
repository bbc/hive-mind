class AddUrlColumnToModels < ActiveRecord::Migration
  def change
    add_column :models, :img_url, :string
  end
end
