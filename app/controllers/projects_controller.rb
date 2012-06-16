class ProjectsController < ApplicationController
  def show
    @project = Project.find_by_name! params[:id]
  end
end
