class AddPrereleaseToVersions < ActiveRecord::Migration
  def up
    add_column :versions, :prerelease, :boolean, null: false, default: false

    Version.select("id, name, version, platform").find_each do |version|
      version.update_column :prerelease, true if version.specification.version.prerelease?
    end

    remove_index :versions, [:name, :version_order]
    add_index :versions, [:name, :version_order, :prerelease]
  end

  def down
    add_index :versions, [:name, :version_order]
    remove_index :versions, [:name, :version_order, :prerelease]

    remove_column :versions, :prerelease
  end
end
