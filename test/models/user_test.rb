require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:one)
    @start_date_1 = DateTime.strptime('2016-01-01 00:00:00', '%Y-%m-%d %H:%M:%S')
    @end_date_1 = DateTime.strptime('2016-02-01 00:00:00', '%Y-%m-%d %H:%M:%S')
    @start_date_2 = DateTime.strptime('2016-03-01 00:00:00', '%Y-%m-%d %H:%M:%S')
    @end_date_2 = DateTime.strptime('2016-04-01 00:00:00', '%Y-%m-%d %H:%M:%S')
  end

  test "climb score" do
    assert_equal(84.375, @user.climb_score_for_period(@start_date_1, @end_date_1), "climb score fail")
  end

  test "climb score difference" do
    assert_equal(2.625, @user.climb_score_difference_for_periods(@start_date_1, @end_date_2, @start_date_1, @end_date_1), "climb score difference fail")
  end
end
