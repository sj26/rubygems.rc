class Version < ActiveRecord::Base
  extend Texticle

  has_many :versions, class_name: "Version", primary_key: "name", foreign_key: "name" do
    def past
      where(arel_table[:version_order].lt(proxy_association.owner.version_order))
    end

    def future
      where(arel_table[:version_order].gt(proxy_association.owner.version_order))
    end

    def other
      where(arel_table[:id].not_eq(proxy_association.owner.id))
    end
  end

  attr_accessible :name, :platform, :version, :summary, :description

  before_save :set_full_name
  before_save :set_version_order, if: :version_changed?
  before_save :set_prerelease, if: :version_changed?
  after_save :update_latest, if: :version_changed?
  after_destroy :find_and_update_latest, if: :latest?

  GEMS_PATH = Rails.root.join("public", "gems")

  def self.prerelease
    where(prerelease: true)
  end

  def self.not_prerelease
    where(prerelease: false)
  end

  def self.ordered
    order("name ASC", "version_order ASC", Arel::Nodes::Ascending.new(Arel::Nodes::SqlLiteral.new("(CASE WHEN platform = 'ruby' THEN (0, NULL) ELSE (1, platform) END)")), "created_at ASC")
  end

  def self.latest
    where(latest: true)
  end

  def self.by_name name
    not_prerelease.where(name: name).latest.first or
      where(name: name).latest.first
  end

  def specification
    Gem::Specification.new(name, version) { |spec| spec.platform = platform }
  end

  def path
    GEMS_PATH.join("#{full_name}.gem").to_s
  end

  def file
    @file ||= GemFile.new path
  end

  def documentation
    @documentation ||= GemDocumentation.new self
  end

  def to_param
    full_name
  end

  def to_s
    full_name
  end

protected

  def set_full_name
    self.full_name = "#{name}-#{version}#{"-#{platform}" unless platform.nil? or platform == "ruby"}"
    true
  end

  def set_version_order
    self.version_order = "{#{Gem::Version.new(version).segments.map { |segment| segment.is_a?(Fixnum) ? %{"(0,#{segment},)"} : %{"(1,0,#{quote_value segment})"} }.join(",")}}"
    true
  end

  def set_prerelease
    self.prerelease = !!Gem::Version.new(version).prerelease?
    true
  end

  def update_latest
    update_column(:latest, !versions.future.where(prerelease: prerelease).exists?)
    versions.past.where(prerelease: prerelease).update_all latest: false
    true
  end

  def find_and_update_latest
    versions.where(prerelease: prerelease).ordered.last.update_latest
    true
  end
end

class VersionSegments
  def type; end

  def type_cast_for_write value
    unless value.nil?
      segments = Gem::Version.new(value).segments
      segments.map! do |segment|
        if segment.is_a?(Fixnum)
          %{"(0,#{segment},)"}
        else
          %{"(1,0,#{quote_value segment})"}
        end
      end
      "{#{segments.join(",")}}"
    end
  end

  QUOTED_STRING = /"(?:\\.|[^"\\])*"/
  UNQUOTED_STRING = /(?:\\.|[^\s,)])*/
  SEGMENT = /\((\d+),(\d+),(?:(#{QUOTED_STRING})|(#{UNQUOTED_STRING}))\)/

  def type_cast value
    unless value.nil?
      value[1...-1].scan(QUOTED_STRING) do |segment|
        segment.match(SEGMENT) do |match|
          pp match
        end
      end
    end
  end
end
