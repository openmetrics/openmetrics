class ProjectsController < ApplicationController

  def index
    add_breadcrumb t('om.navigation.projects')
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      flash[:success] = "Project saved."
    else
      flash[:warn] = "Oh snap! That didn't work."
    end
    redirect_to :back
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update!(project_params)
      flash[:success] = "Test case updated."
    else
      flash[:warn] = 'Something went wrong while updating project.'
    end
    redirect_to :back
  end

  def destroy
    @project = Project.find(params[:id])
    if @project.destroy!
      flash[:success] = "Project deleted."
    end
    redirect_to :back
  end

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
