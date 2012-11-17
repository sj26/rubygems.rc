class ModifyVersionOrder < ActiveRecord::Migration
  class Version < ActiveRecord::Base
    def self.reorder_up!
    end

    def reorder_up!
      segments = Gem::Version.new(version).segments
      segments.map! { |segment| segment.is_a?(Fixnum) ? [0, segment, ""] : [1, 0, segment] }
      sql = Array.new(segments.length, "ROW(?, ?, ?)::version_segment").join(", ")
      sql = "ARRAY[#{sql}]"
      update_column :version_order
    end
  end

  def up
    execute "CREATE TYPE version_segment AS (i integer, d numeric, s text)"
    remove_column :versions, :version_order
    add_column :versions, :version_order, "version_segment[]", after: :version
    remove_index :versions, [:name, :version, :platform]
    add_index :versions, [:name, :version_order, :platform], unique: true
  end

  def down
    remove_column :versions, :version_order
    add_column :versions, :version_order, :integer, after: :version
    add_index :versions, [:name, :version, :platform], unique: true
    execute "DROP TYPE version_segment"
  end
end
