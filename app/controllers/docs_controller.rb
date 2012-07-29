class DocsController < ApplicationController
  before_filter :prepare_version
  before_filter :generate_documentation, only: [:show, :status]
  before_filter :redirect_blank_to_index, only: :show

  layout "version"

  def show
    if params[:format].in? ["html", nil]
      render text: @version.documentation["#{params[:path]}.html"], layout: true
    else
      send_file @version.documentation["#{params[:path]}.#{params[:format]}"]
    end
  end

  def status
    render json: @version.documentation.status
  end

protected

  def prepare_version
    @version = Version.find_by_full_name! params[:version_id]
  end

  def generate_documentation
    if not @version.documentation.ready?
      @version.documentation.generate
      render "generating"
    end
  end

  def redirect_blank_to_index
    redirect_to path: "index", format: params[:format] || "html" if params[:path].blank?
  end
end
