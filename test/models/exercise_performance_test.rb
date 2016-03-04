require 'test_helper'

class ExercisePerformanceTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @user2 = users(:two)
    @performance = exercise_performances(:one)
  end

  test "quantification" do
    quantification = @performance.quantify
    assert_equal("crimp", quantification[:name], 'quantification name off')
    assert_equal(58.96696, quantification[:value], 'quantification value off')
  end
end
