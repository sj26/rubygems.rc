namespace :gems do
  task import: [:environment] do
    Dir["#{Rails.root}/public/gems/*.gem"].each do |path|
      spec = Gem::Format.from_file_by_path(path).spec
      project = Project.find_or_create_by_name! spec.name
      project.versions.find_or_create_by_version_and_platform! version: spec.version.to_s, platform: spec.platform do |version|
        version.summary = spec.summary
        version.description = spec.description unless spec.description == spec.summary
      end
      puts spec.full_name
    end
    Project.find_each(&:reorder_versions!)
  end
end
