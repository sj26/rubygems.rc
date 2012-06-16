class SearchController < ApplicationController
  def new
  end

  def create
    @projects = Project.search params[:query]
  end
end
