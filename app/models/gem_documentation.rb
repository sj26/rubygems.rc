# Manages documentation for a gem version.
class GemDocumentation
  attr_reader :version

  YARD_PATH = "#{Rails.root}/tmp/cache/yard".freeze
  YARD_PATTERNS = ["app/**.rb", "lib/**.rb", "ext/**.c"].freeze

  YARD::Templates::Engine.template_paths << "#{Rails.root}/lib/yard-templates"

  def initialize version
    @version = version
  end

  delegate :file, to: :version
  delegate :metadata, to: :file
  delegate :extra_rdoc_files, to: :metadata
  delegate :rdoc_options, to: :metadata

  def rdoc_options_main
    @rdoc_options_main ||= rdoc_options.present? and
      (rdoc_options.include? "--main" and
        rdoc_options[rdoc_options.index("--main") + 1].presence) or
      (rdoc_options.include? "-m" and
        rdoc_options[rdoc_options.index("-m") + 1].presence)
  end

  def readme
    @readme ||= rdoc_options_main || file.glob("README*").sort_by(&:length).first
  end

  def extra_files
    @extra_files ||= (extra_rdoc_files - [readme])
  end

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
    extra_file_objects = []
    readme_object = nil
    file.data_tar do |data_tar|
      data_tar.each do |entry|
        if YARD_PATTERNS.any? { |pattern| File.fnmatch(pattern, entry.full_name) }
          parser = YARD::Parser::SourceParser.new(YARD::Parser::SourceParser.parser_type, globals)
          parser.send :file=, entry.full_name
          parser.send :parser_type=, parser.send(:parser_type_for_filename, entry.full_name)
          parser.parse entry
          # TODO: Check multilingual source code is correclty encoded/parsed.
        elsif entry.full_name == readme
          readme_object = YARD::CodeObjects::ExtraFileObject.new(entry.full_name, entry.read.detect_encoding!)
        elsif entry.full_name.in? extra_files
          extra_file_objects << YARD::CodeObjects::ExtraFileObject.new(entry.full_name, entry.read.detect_encoding!)
        end
      end
    end
    objects = YARD::Registry.all(:root, :module, :class)
    serializer = YARD::Serializers::FileSystemSerializer.new(basepath: yard_doc_path)
    YARD::Templates::Engine.generate objects,
      basepath: yard_doc_path,
      format: :html,
      globals: globals,
      files: extra_file_objects + [readme_object].compact,
      readme: readme_object,
      markup: :rdoc,
      serializer: serializer,
      template: :rubygems
    Rails.logger.info "Generated documentation for #{version.inspect}: #{objects.size} objects: #{objects.inspect}"
    YARD::Registry.save
  rescue
    Rails.logger.error "Error generating documentation for #{version.inspect}:\n#{$!.class.name}: #{$!}\n#{$!.backtrace.join("\n")}"
    FileUtils.rm_rf yard_yardoc_path
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
