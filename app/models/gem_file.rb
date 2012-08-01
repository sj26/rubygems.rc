class GemFile
  attr_reader :path

  def initialize path
    raise "gem file not found" unless File.exists? path
    @path = path.dup.freeze
  end

  def specification
    @specification ||= metadata
  end

  def tar_file &block
    File.open path, &block
  end

  def tar &block
    tar_file do |file|
      Gem::Package::TarReader.new file, &block
    end
  end

  def metadata_file &block
    tar do |tar|
      tar.each do |entry|
        return gzipped_file entry, &block if entry.full_name == "metadata.gz"
        return yield entry if entry.full_name == "metadata"
      end
    end
    raise "metadata file not found"
  end

  def metadata
    @metadata ||= Rails.cache.fetch "GemFile/#{path}/metadata" do
      metadata_file do |metadata_file|
        Gem::Specification.from_yaml metadata_file
      end
    end
  end

  def data_tar_file &block
    tar do |tar|
      tar.each do |entry|
        return gzipped_file entry, &block if entry.full_name == "data.tar.gz"
        return block.call(entry) if entry.full_name == "data.tar"
      end
    end
    raise "data file not found"
  end

  def data_tar &block
    data_tar_file do |data_tar_file|
      Gem::Package::TarReader.new data_tar_file, &block
    end
  end

  def data_file path, &block
    data_tar do |data_tar|
      data_tar.each do |entry|
        if entry.full_name == path
          return yield entry
        end
      end
    end
    raise "file #{path.inspect} not found"
  end

  def headers
    @headers ||= Rails.cache.fetch "GemFile/#{path}/headers" do
      {}.tap do |hash|
        data_tar do |data_tar|
          data_tar.each do |entry|
            hash[entry.full_name] = entry.header
          end
        end
      end.freeze
    end
  end

  def paths
    @paths ||= headers.keys
  end

  def tree
    @tree ||= Rails.cache.fetch "GemFile/#{path}/tree" do
      {}.tap do |hash|
        headers.each do |path, header|
          components = path.split('/')
          components[0...-1].inject(hash) { |hash, component| hash[component] ||= {} }[components.last] = header
        end
      end.freeze
    end
  end

  alias to_hash tree

  def [] path
    path.split('/').compact.inject(tree) { |paths, component| paths[component] }
  end

  def glob pattern, flags=0
    paths.select { |path| File.fnmatch(pattern, path, flags) }
  end

  def readme
    glob("README*", File::FNM_CASEFOLD).sort_by(&:length).first
  end

protected

  def gzipped_file file, &block
    begin
      gz = Zlib::GzipReader.new file
      yield gz
    ensure
      gz.close if gz
    end
  end
end
