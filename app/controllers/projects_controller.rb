class ProjectsController < ApplicationController
  def index
    @projects = Project.order(:name).paginate page: params[:page] || 1
    @projects = @projects.search params[:search] if search?
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
