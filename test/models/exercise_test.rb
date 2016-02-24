require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @user2 = users(:two)
    @exercise = exercises(:deadhang)
  end

  test "duplicate for same user" do
    new_exercise = @exercise.duplicate(@user)
    assert_equal(@exercise.user_id, new_exercise.user_id, "user incorrect")
    assert_equal(@exercise.exercise_type, new_exercise.exercise_type, "type incorrect")
    assert_equal(@exercise.label + " (copy)", new_exercise.label, "label incorrect")
    assert_equal(@exercise.exercise_metrics.count, new_exercise.exercise_metrics.count, "metrics incorrect")
  end

  test "duplicate for different user" do
    new_exercise = @exercise.duplicate(@user2)
    assert_equal(@user2.id, new_exercise.user_id, "user incorrect")
  end

end
