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
    Marshal.load(Zlib.inflate(File.read(Rails.root.join('public', 'Marshal.4.8.Z')))).tap do |specs|
      progress = Gem::ProgressBar.new "Seeding gems", specs.length
    end.each do |full_name, spec|
      begin
        Version.find_or_create_by_name_and_version_and_platform!(spec.name.to_s, spec.version.to_s, spec.platform.to_s) do |version|
          spec_summary = spec.summary.try(:force_encoding, "utf-8").try(:strip).presence
          spec_description = spec.description.try(:force_encoding, "utf-8").try(:strip).presence
          version.summary = spec_summary
          version.description = spec_description unless spec_description == spec_summary
        end
      rescue
        puts $!, $!.message, *$!.backtrace
      end
      progress.inc
    end
    progress.finish
    puts "#{progress.total} gems seeded"
  end
end

desc "Mirror, index and seed gems"
task gems: %w(gems:mirror gems:index gems:seed)
