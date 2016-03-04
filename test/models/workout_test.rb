require 'test_helper'

class WorkoutTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @user2 = users(:two)
    @workout = workouts(:hangboard)
  end

  # test "all efficacy" do
  #   @workout = workouts(:hangboard)
  #   assert_equal(24, @workout.efficacy, "efficacy off")
  # end
  #
  # test "boulder efficacy" do
  #   @workout = workouts(:hangboard)
  #   assert_equal(24, @workout.efficacy("boulder"), "boulder efficacy off")
  # end

  test "duplicate for same user" do
    new_workout = @workout.duplicate(@user)
    assert_equal(@workout.user_id, new_workout.user_id, "user incorrect")
    assert_equal(@workout.workout_type, new_workout.workout_type, "type incorrect")
    assert_equal(@workout.label + " (copy)", new_workout.label, "label incorrect")
    assert_equal(@workout.workout_exercises.count, new_workout.workout_exercises.count, "workout_exercises incorrect")
    assert_equal(@workout.workout_metrics.count, new_workout.workout_metrics.count, "workout_metrics incorrect")
  end


  test "don't duplicate exercise with same reference_id" do
    new_workout = @workout.duplicate(@user2)
    assert_equal(2, @user2.exercises.count, "made an unnecessary copy")
  end

  test "progress" do
    progress = @workout.progress
    crimp_progress = progress["crimp"]
    assert_equal("Jan 11, 2016", crimp_progress[:date], "progress date off, remember formatting")
    assert_equal(58.97, crimp_progress[:value], "progress value off, remember rounding")
  end

end
