require 'test_helper'

class WorkoutTest < ActiveSupport::TestCase
  test "all efficacy" do
    @workout = workouts(:hangboard)
    assert_equal(24, @workout.efficacy, "efficacy off")
  end

  test "boulder efficacy" do
    @workout = workouts(:hangboard)
    assert_equal(24, @workout.efficacy("boulder"), "boulder efficacy off")
  end
end
