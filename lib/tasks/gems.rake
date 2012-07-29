require 'zlib'
require "#{Rails.root}/vendor/gem/lib/gem/progressbar"

namespace :gems do
  desc "Mirror gems"
  task :mirror do
    system({"RUBYOPT" => nil}, "ruby", "--disable-gems", "-I", "#{Rails.root}/vendor/gem/lib", "#{Rails.root}/vendor/gem/bin/gem", "mirror", chdir: "#{Rails.root}/public")
  end

  desc "Index gems"
  task :index do
    system({"RUBYOPT" => nil}, "ruby", "--disable-gems", "-I", "#{Rails.root}/vendor/gem/lib", "#{Rails.root}/vendor/gem/bin/gem", "index", chdir: "#{Rails.root}/public")
  end

  desc "Seed gems into database"
  task seed: :environment do
    progress = nil
    Marshal.load(Zlib.inflate(File.read('public/Marshal.4.8.Z'))).tap do |specs|
      progress = Gem::ProgressBar.new "Seeding gems", specs.length
    end.each do |full_name, spec|
      project = Project.find_or_create_by_name! spec.name.to_s
      version = project.versions.find_or_create_by_version_and_platform! spec.version.to_s, spec.platform.to_s
      version.summary = spec.summary.try(:strip)
      version.description = spec.description.try(:strip) unless spec.description.try(:strip) == version.summary
      version.save!
      progress.inc
    end
    progress.finish
    puts "#{progress.total} gems seeded"
  end

  # This will go away once we can sematically sort versions in postgresql (hence undocumented)
  task reorder: :environment do
    progress = Gem::ProgressBar.new "Reordering versions", Project.count
    Project.find_each do |project|
      project.reorder_versions!
      progress.inc
    end
    progress.finish
  end
end

desc "Mirror, index and seed gems"
task gems: %w(gems:mirror gems:index gems:seed gems:reorder)
