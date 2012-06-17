class ChangeVersionIndex < ActiveRecord::Migration
  def change
    remove_index :versions, [:project_id, :version], unique: true
    add_index :versions, [:project_id, :version, :platform], unique: true
  end
end
