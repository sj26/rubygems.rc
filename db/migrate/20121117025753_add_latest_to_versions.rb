class AddLatestToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :latest, :boolean, null: false, default: false
  end
end
