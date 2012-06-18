require 'zlib'

namespace :gems do
  task import: [:environment] do
    Marshal.load(Zlib.inflate(File.read('public/Marshal.4.8.Z'))).each do |full_name, spec|
      project = Project.find_or_create_by_name! spec.name.to_s
      version = project.versions.find_or_create_by_version_and_platform! spec.version.to_s, spec.platform.to_s
      version.summary = spec.summary
      version.description = spec.description unless spec.description == spec.summary
      version.save!
      puts version
    end
    Project.find_each(&:reorder_versions!)
  end

  task old_import: [:environment] do
    Dir["#{Rails.root}/public/gems/*.gem"].each do |path|
      if spec = Gem::Format.from_file_by_path(path).try(:spec)
        project = Project.find_or_create_by_name! spec.name
        project.versions.find_or_create_by_version_and_platform! version: spec.version.to_s, platform: spec.platform.to_s do |version|
          version.summary = spec.summary
          version.description = spec.description unless spec.description == spec.summary
        end
        puts spec.full_name
      end
    end
    Project.find_each(&:reorder_versions!)
  end
end
