# Manages documentation for a gem version.
class GemDocumentation
  attr_reader :version

  YARD_PATH = "#{Rails.root}/tmp/yard"
  YARD_PATTERNS = ["lib/**.rb", "ext/**.c"]

  YARD::Templates::Engine.template_paths << "#{Rails.root}/lib/yard-templates"

  def initialize version
    @version = version
  end

  delegate :file, to: :version

  def yard_path
    "#{YARD_PATH}/#{version.full_name}"
  end

  def yard_yardoc_path
    "#{yard_path}/.yardoc"
  end

  def yard_doc_path
    "#{yard_path}/doc"
  end

  def generate
    unless File.exist? yard_yardoc_path
      Thread.new(&method(:generate!))
    end
  end

  def generate!
    FileUtils.mkdir_p yard_path
    FileUtils.touch yard_yardoc_path
    YARD::Registry.clear
    YARD::Registry.yardoc_file = yard_yardoc_path
    globals = OpenStruct.new
    file.data_tar do |data_tar|
      data_tar.each do |entry|
        if YARD_PATTERNS.any? { |pattern| File.fnmatch(pattern, entry.full_name) }
          parser = YARD::Parser::SourceParser.new(YARD::Parser::SourceParser.parser_type, globals)
          parser.send :file=, entry.full_name
          parser.send :parser_type=, parser.send(:parser_type_for_filename, entry.full_name)
          parser.parse entry
        end
      end
    end
    objects = YARD::Registry.all(:root, :module, :class)
    serializer = YARD::Serializers::FileSystemSerializer.new(basepath: yard_doc_path)
    YARD::Templates::Engine.generate objects,
      basepath: yard_doc_path,
      format: :html,
      globals: globals,
      files: [],
      serializer: serializer,
      template: :rubygems
    Rails.logger.info "Generated documentation for #{version.inspect}: #{objects.size} objects: #{objects.inspect}"
    YARD::Registry.save
  rescue
    Rails.logger.error "Error generating documentation for #{version.inspect}:\n#{$!.class.name}: #{$!}\n#{$!.backtrace.join("\n")}"
    File.open(yard_yardoc_path, "w") { |file| file.write "error" }
    raise
  end

  def status
    if File.directory? yard_yardoc_path
      :ready
    elsif File.size? yard_yardoc_path
      :error
    else
      nil
    end
  end

  def ready?
    status == :ready
  end

  def [] path
    File.read File.join(yard_doc_path, path)
  end
end
