class VersionsController < ApplicationController
  before_filter :prepare_version
  before_filter :prepare_gem_file, only: [:browse, :raw]

  def show
  end

  def browse
  end

  # TODO: This should be cached.
  def raw
    @gem_file.data_file(@path) do |file|
      send_data file.data, filename: file.name, type: file.content_type, disposition: file.disposition
    end
  end

protected

  def prepare_version
    @version = Version.find_by_full_name! params[:id]
  end

  def prepare_gem_file
    gem_path = "#{Rails.root}/public/gems/#{params[:id]}.gem"
    @gem_file = GemFile.new gem_path
    @path = params[:path] || ""
    @entry = @gem_file[@path]
  end
end
