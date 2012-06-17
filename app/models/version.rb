class Version < ActiveRecord::Base
  attr_accessible :platform, :version

  belongs_to :project

  delegate :name, to: :project

  default_scope order(:project_id, "version_order desc", "created_at desc")

  def self.with_full_name full_name
    joins(:project).where("(projects.name || '-' || versions.version = ? AND versions.platform = 'ruby') OR projects.name || '-' || versions.version || '-' || versions.platform = ?", full_name, full_name).order("versions.platform DESC")
  end

  def self.find_by_full_name! full_name
    with_full_name(full_name).first!
  end

  def full_name
    "#{name}-#{version}#{"-#{platform}" unless platform.nil? or platform == "ruby"}"
  end

  def to_param
    full_name
  end

  def to_s
    full_name
  end
end
