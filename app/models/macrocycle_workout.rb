class MacrocycleWorkout < ActiveRecord::Base
  belongs_to :macrocycle
  belongs_to :workout
end