class AddOrderToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :version_order, :integer, null: false, default: 0
    add_index :versions, [:project_id, :version_order, :created_at]
  end
end
