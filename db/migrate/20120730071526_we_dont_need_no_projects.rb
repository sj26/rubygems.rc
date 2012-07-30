class WeDontNeedNoProjects < ActiveRecord::Migration
  def up
    add_column :versions, :name, :string
    execute "UPDATE versions SET name = projects.name FROM projects WHERE projects.id = versions.project_id"
    change_column :versions, :name, :string, null: false

    remove_index :versions, [:project_id, :version, :platform]
    add_index :versions, [:name, :version, :platform], unique: true

    remove_index :versions, [:project_id, :version_order, :created_at]
    add_index :versions, [:name, :version_order]

    remove_column :versions, :project_id

    drop_table :projects
  end
end
