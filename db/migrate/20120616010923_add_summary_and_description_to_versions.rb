class AddSummaryAndDescriptionToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :summary, :text
    add_column :versions, :description, :text
  end
end
