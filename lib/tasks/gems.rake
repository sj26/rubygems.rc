require 'zlib'

namespace :gems do
  task import: [:environment] do
    Marshal.load(Zlib.inflate(File.read('public/Marshal.4.8.Z'))).each do |full_name, spec|
      project = Project.find_or_create_by_name! spec.name.to_s
      version = project.versions.find_or_create_by_version_and_platform! spec.version.to_s, spec.platform.to_s
      version.summary = spec.summary.strip
      version.description = spec.description.strip unless spec.description.strip == version.summary
      version.save!
      puts version
    end
    Project.find_each(&:reorder_versions!)
  end
end
