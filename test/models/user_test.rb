require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:one)
    @user2 = users(:two)
    @start_date_1 = DateTime.strptime('2016-01-01 00:00:00', '%Y-%m-%d %H:%M:%S')
    @end_date_1 = DateTime.strptime('2016-02-01 00:00:00', '%Y-%m-%d %H:%M:%S')
    @start_date_2 = DateTime.strptime('2016-03-01 00:00:00', '%Y-%m-%d %H:%M:%S')
    @end_date_2 = DateTime.strptime('2016-04-01 00:00:00', '%Y-%m-%d %H:%M:%S')
  end

  test "climb score" do
    assert_equal(93.75, @user.climb_score_for_period(@start_date_1, @end_date_1), "climb score fail")
  end

  test "climb score difference" do
    assert_equal(5.75, @user.climb_score_difference_for_periods(@start_date_1, @end_date_2, @start_date_1, @end_date_1), "climb score difference fail")
  end

  test "agnostic weight" do
    assert_equal(63.50288, @user.agnostic_weight(140), "weight conversion off")
    assert_equal(140, @user2.agnostic_weight(140), "weight non-conversion off")
  end
end
