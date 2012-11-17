class VersionsController < ApplicationController
  before_filter :prepare_version, only: [:show, :other, :browse, :raw]
  before_filter :prepare_entry, only: [:browse, :raw]

  layout "version", except: :index

  def index
    @versions = Version.latest
    if search?
      @exact_version = @versions.latest.by_name params[:search]
      @versions = @versions.where("id != ?", @exact_version) if @exact_version
      @versions = @versions.search(params[:search]).where("version_order = MAX(version_order) OVER (PARTITION BY name)")
    else
      @versions = @versions.ordered
    end
    @versions = @versions.paginate page: params[:page] || 1
  end

  def show
  end

  def other
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

  def search?
    params[:search].present?
  end

  helper_method :search?

  def prepare_version
    @version = Version.find_by_full_name! params[:id]
  rescue ActiveRecord::RecordNotFound
    if @version = Version.by_name(params[:id])
      redirect_to @version
    else
      redirect_to versions_path(search: params[:id])
    end
  end

  def prepare_entry
    @path = params[:path] || ""
    @entry = @version.file[@path]
  end
end
