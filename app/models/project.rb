class Project < ActiveRecord::Base
  attr_accessible :name

  has_many :versions, dependent: :destroy
  belongs_to :latest_version, class_name: "Version"

  # summary and description come from latest versions.

  extend Texticle

  # Would prefer using a postgresql type and custom comparison
  # operator, but that rabbit hole's too deep for railscamp.
  def reorder_versions!
    versions.all.sort_by do |version|
      [Gem::Version.new(version.version), version.platform]
    end.each.with_index do |version, position|
      version.update_attribute :version_order, position
    end.first.tap do |latest_version|
      self.latest_version = latest_version
      self.summary = latest_version.summary
      self.description = latest_version.summary
    end
    save!
  end

  def to_param
    name
  end

  def to_s
    name
  end
end
