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
        case entry.full_name
          when "metadata.gz"
            gzipped_file entry, &block
            return
          when "metadata"
            yield entry
            return
        end
      end
    end
    raise "metadata file not found"
  end

  def metadata
    @metadata ||= Rails.cache.fetch "GemFile/#{path}/metadata" do
      metadata_file do |metadata_file|
        return Gem::Specification.from_yaml metadata_file
      end
    end
  end

  def data_tar_file &block
    tar do |tar|
      tar.each do |entry|
        gzipped_file entry, &block if entry.full_name == "data.tar.gz"
        return
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

  def to_hash
    @hash ||= Rails.cache.fetch "GemFile/#{path}/hash" do
      {}.tap do |paths|
        data_tar do |data_tar|
          data_tar.each do |entry|
            components = entry.full_name.split('/')
            components[0...-1].inject(paths) { |paths, component| paths[component] ||= {} }[components.last] = entry.header
          end
        end
      end.freeze
    end
  end

  def [] path
    path.split('/').compact.inject(to_hash) { |paths, component| paths[component] }
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
