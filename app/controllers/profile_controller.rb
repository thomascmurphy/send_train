class ProfileController < ApplicationController
  def show
    @user = current_user
    @next_events = current_user.events.where.not(workout_id: nil, completed: true).order(start_date: :asc).first(2)
    @best_workouts_bouldering = current_user.workouts.sort_by{|w| w.efficacy("boulder")}.reverse[0..1]
    @best_workouts_sport_climbing = current_user.workouts.sort_by{|w| w.efficacy("sport")}.reverse[0..1]
  end
end
