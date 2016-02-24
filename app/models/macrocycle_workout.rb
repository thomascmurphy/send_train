class MacrocycleWorkout < ActiveRecord::Base
  belongs_to :macrocycle
  belongs_to :workout

  def duplicate(user, new_workout_id, new_macrocycle_id)
    new_macrocycle_workout = self.dup
    new_macrocycle_workout.workout_id = new_workout_id
    new_macrocycle_workout.macrocycle_id = new_macrocycle_id
    if new_macrocycle_workout.save
      return new_macrocycle_workout
    end
  end
end
