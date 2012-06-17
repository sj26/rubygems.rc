class Project < ActiveRecord::Base
  attr_accessible :name

  has_many :versions, dependent: :destroy

  delegate :summary, :description, to: :latest_version

  extend Texticle

  def latest_version
    versions.first
  end

  # Would prefer using a postgresql type and custom comparison
  # operator, but that rabbit hole's too deep for railscamp.
  def reorder_versions!
    versions.all.sort_by { |version|
      [Gem::Version.new(version.version), version.platform]
    }.each.with_index { |version, position|
      version.update_attribute :version_order, position
    }
  end

  def to_param
    name
  end

  def to_s
    name
  end
end
