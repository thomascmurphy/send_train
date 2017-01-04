class GoalsController < ApplicationController

  def index
    @ongoing_goals = Goal.where(user_id: current_user.id, parent_goal_id: nil, completed: false)
    @completed_goals = Goal.where(user_id: current_user.id, parent_goal_id: nil, completed: true)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @goals, status: :ok, location: @goals }
    end
  end

  def show
    @goal = current_user.goals.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @goal, status: :ok, location: @goal }
    end
  end

  def new
    @goal = current_user.goals.new
    if params[:parent_goal_id].present?
      @goal.parent_goal_id = params[:parent_goal_id]
    end
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @goal, status: :created, location: @goal }
    end
  end

  def create
    @ongoing_goals = Goal.where(user_id: current_user.id, parent_goal_id: nil, completed: false)
    @completed_goals = Goal.where(user_id: current_user.id, parent_goal_id: nil, completed: true)
    deadline = params[:date]
    if deadline.present?
      if deadline[:day].present? && deadline[:month].present? && deadline[:year].present?
        goal_deadline = DateTime.strptime("#{deadline[:year]} #{deadline[:month]} #{deadline[:day]}", "%Y %m %d")
        params[:goal][:deadline] = goal_deadline
      end
    end
    @goal = current_user.goals.new(goal_params)

    respond_to do |format|
      if @goal.save
        format.html { redirect_to @goal, notice: 'Goal was successfully created.' }
        format.js
        format.json { render json: @goal, status: :created, location: @goal }
      else
        format.html { render action: "new" }
        format.json { render json: @goal.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @goal = current_user.goals.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @goal, status: :ok, location: @goal }
    end
  end

  def update
    @ongoing_goals = Goal.where(user_id: current_user.id, parent_goal_id: nil, completed: false)
    @completed_goals = Goal.where(user_id: current_user.id, parent_goal_id: nil, completed: true)
    @goal = current_user.goals.find_by_id(params[:id])
    deadline = params[:date]
    if deadline.present?
      if deadline[:day].present? && deadline[:month].present? && deadline[:year].present?
        goal_deadline = DateTime.strptime("#{deadline[:year]} #{deadline[:month]} #{deadline[:day]}", "%Y %m %d")
        params[:goal][:deadline] = goal_deadline
      end
    end

    respond_to do |format|
      if @goal.update_attributes(goal_params)
        format.html
        format.js
        format.json { render json: @goal, status: :ok, location: @goal }
      else
        format.html
        format.js
        format.json { render json: @goal.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @goal = current_user.goals.find_by_id(params[:goal_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @ongoing_goals = Goal.where(user_id: current_user.id, parent_goal_id: nil, completed: false)
    @completed_goals = Goal.where(user_id: current_user.id, parent_goal_id: nil, completed: true)
    @goal = current_user.goals.find_by_id(params[:id])
    @goal.destroy
  end

  private

  def goal_params
    params.require(:goal).permit(:label, :parent_goal_id, :public, :deadline, :completed)
  end

end
