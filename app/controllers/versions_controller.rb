class VersionsController < ApplicationController
  before_filter :prepare_version
  before_filter :prepare_entry, only: [:browse, :raw]

  layout "version"

  def show
  end

  def browse
  end

  # TODO: This should be cached.
  def raw
    @version.file.data_file(@path) do |file|
      send_data file.data, filename: file.name, type: file.content_type, disposition: file.disposition
    end
  end

protected

  def prepare_version
    @version = Version.find_by_full_name! params[:id]
  rescue ActiveRecord::RecordNotFound
    if @project = Project.find_by_name(params[:id])
      redirect_to @project
    end
  end

  def prepare_entry
    @path = params[:path] || ""
    @entry = @version.file[@path]
  end
end
