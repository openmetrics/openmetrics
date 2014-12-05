class ProjectsController < ApplicationController

  def index
    add_breadcrumb 'Projects List'
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
    redirect_via_turbolinks_to(project_path(@project))
  end

  def edit
    @project = Project.find(params[:id])
  end

  # run all TestPlan's related to this Project
  def run
    p = Project.find(params[:id])
    p.test_plans.each do |tp|
      te = TestExecution.new(test_plan: tp, user_id: current_user.id)
      if te.save
        tp.create_activity :run, :owner => current_user, :parameters => {:test_execution_id => te.id}
      end
    end
    flash[:success] = "Project's Test Plans successfully scheduled."
    redirect_via_turbolinks_to(project_path(p))
  end

  def update
    @project = Project.find(params[:id])
    if @project.update!(project_params)
      flash[:success] = "Project updated."
    else
      flash[:warn] = 'Something went wrong while updating project.'
    end
    redirect_via_turbolinks_to(:back)
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
