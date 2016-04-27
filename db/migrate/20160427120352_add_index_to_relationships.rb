class AddIndexToRelationships < ActiveRecord::Migration
  def change
    add_index :relationships, :primary_id
    add_index :relationships, :secondary_id
  end
end
