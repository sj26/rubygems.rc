class Version < ActiveRecord::Base
  attr_accessible :platform, :version

  belongs_to :project

  delegate :name, to: :project

  default_scope order(:project_id, :version_order, "created_at desc")

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
