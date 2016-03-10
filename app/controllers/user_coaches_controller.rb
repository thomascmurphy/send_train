class UserCoachesController < ApplicationController

  def new
    @user_coach = UserCoach.new(user_id: current_user.id)
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def create
    coach = User.find_by_email(params[:email])
    if coach.present?
      @user = current_user
      @user_coach = UserCoach.new(user_id: current_user.id, coach_id: coach.id)
      if @user.coaches.where(coach_id: coach.id).present?
        @user_coach.errors.add(:base, "You have already added that user as a coach.")
        respond_to do |format|
          format.html
          format.js
          format.json { render json: @user_coach.errors, status: :unprocessable_entity }
        end
      else
        respond_to do |format|
          if @user_coach.save
            format.html { redirect_to @user_coach, notice: 'Coach was successfully added.' }
            format.js
            format.json { render json: @user_coach, status: :created, location: @user_coach }
          else
            format.html { render action: "new" }
            format.json { render json: @user_coach.errors, status: :unprocessable_entity }
          end
        end
      end
    else
      @user_coach.errors.add(:base, "There is no user associated with that email.")
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @user_coach.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @user_coach = current_user.coaches.find_by_id(params[:user_coach_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @user = current_user
    @user_coach = current_user.coaches.find_by_id(params[:id])
    @user_coach.destroy
  end

  def my_students
    @students = current_user.students
  end

  private
    def user_coach_params
      params.require(:user_coach).permit(:coach_id)
    end
end
