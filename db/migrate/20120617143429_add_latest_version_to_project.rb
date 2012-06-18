class AddLatestVersionToProject < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.references :latest_version
      t.text :summary, :description
    end
  end
end
