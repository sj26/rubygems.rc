class ProjectsController < ApplicationController
  def index
    @projects = Project.scoped
    if search?
      @projects = @projects.search params[:search] if search?
      @project = Project.find_by_name params[:search] if (params[:page] || 1).to_i == 1
    else
      @projects = @projects.order(:name)
    end
    @projects = @projects.paginate page: params[:page] || 1
  end

  def show
    @project = Project.find_by_name! params[:id]
  end

protected

  def search?
    params[:search].present?
  end

  helper_method :search?
end
