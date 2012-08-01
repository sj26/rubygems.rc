class Version < ActiveRecord::Base
  extend Texticle

  attr_accessible :name, :platform, :version, :summary, :description

  has_many :all_versions, class_name: "Version", primary_key: "name", foreign_key: "name"

  def self.with_full_name full_name
    where("(name || '-' || version = ? AND platform = 'ruby') OR name || '-' || version || '-' || platform = ?", full_name, full_name).order("platform DESC")
  end

  def self.find_by_full_name! full_name
    with_full_name(full_name).first!
  end

  def self.prerelease
    where(prerelease: true)
  end

  def self.not_prerelease
    where(prerelease: false)
  end

  def self.ordered
    order("name ASC", "version_order ASC", "created_at DESC")
  end

  def self.find_using_name name
    where(name: name).not_prerelease.ordered.first or
      where(name: name).ordered.first
  end

  def full_name
    "#{name}-#{version}#{"-#{platform}" unless platform.nil? or platform == "ruby"}"
  end

  def filename
    Rails.root.join("public", "gems", "#{full_name}.gem").to_s
  end

  def specification
    Gem::Specification.new(name, version) { |spec| spec.platform = platform }
  end

  def file
    @file ||= GemFile.new filename
  end

  def documentation
    @documentation ||= GemDocumentation.new self
  end

  def other_versions
    all_versions.where("id != ?", id)
  end

  def to_param
    full_name
  end

  def to_s
    full_name
  end

  # Temporary sorting until postgres can sort specifications properly:

  # after_save :reorder!

  def self.reorder! scope=scoped
    tap do
      scope.order("name ASC").pluck("DISTINCT name").each do |name|
        transaction do
          scope.where(name: name).select("id, name, version, platform").sort do |b, a|
            if a.name != b.name
              a.name <=> b.name
            elsif a.version != b.version
              a.specification.version <=> b.specification.version
            elsif a.platform == "ruby" and b.platform != "ruby"
              1
            elsif a.platform != "ruby" and b.platform == "ruby"
              -1
            elsif a.platform != b.platform
              a.platform <=> b.platform
            else
              a.created_at <=> b.created_at
            end
          end.each.with_index do |version, position|
            version.update_column :version_order, position
          end
        end
      end
    end
  end

  def reorder!
    tap { self.class.reorder! all_versions }
  end
end
