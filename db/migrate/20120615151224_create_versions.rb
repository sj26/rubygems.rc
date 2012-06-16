class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.references :project, null: false
      t.string :version
      t.string :platform

      t.timestamps
    end

    add_index :versions, [:project_id, :version], unique: true
  end
end
