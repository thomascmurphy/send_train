require 'test_helper'

class MacrocycleTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @user2 = users(:two)
    @macrocycle = macrocycles(:macro)
  end

  test "duplicate for same user" do
    new_macrocycle = @macrocycle.duplicate(@user)
    assert_equal(@macrocycle.user_id, new_macrocycle.user_id, "user incorrect")
    assert_equal(@macrocycle.macrocycle_type, new_macrocycle.macrocycle_type, "type incorrect")
    assert_equal(@macrocycle.label + " (copy)", new_macrocycle.label, "label incorrect")
    assert_equal(@macrocycle.macrocycle_workouts.count, new_macrocycle.macrocycle_workouts.count, "workout_exercises incorrect")
  end

  test "duplicate for different user" do
    new_macrocycle = @macrocycle.duplicate(@user2)
    assert_equal(@user2.id, new_macrocycle.user_id, "user incorrect")
    assert_equal(@macrocycle.macrocycle_type, new_macrocycle.macrocycle_type, "type incorrect")
    assert_equal(@macrocycle.label, new_macrocycle.label, "label incorrect")
    assert_equal(@macrocycle.macrocycle_workouts.count, new_macrocycle.macrocycle_workouts.count, "workout_exercises incorrect")
  end
end
