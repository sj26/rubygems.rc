class AddFullNameToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :full_name, :string, null: false
    add_index :versions, :full_name
  end
end
