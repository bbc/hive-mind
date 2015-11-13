class DropAttributes < ActiveRecord::Migration
  def change
    drop_table :hive_mind_hive_attributes
  end
end
