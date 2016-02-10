require 'test_helper'

class WorkoutTest < ActiveSupport::TestCase
  test "all efficacy" do
    @workout = workouts(:hangboard)
    assert_equal(14, @workout.efficacy, "efficacy off")
  end
end
