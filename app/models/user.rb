class User < ActiveRecord::Base
  has_many :climbs
  has_many :attempts, through: :climbs
  has_many :events
  has_many :macrocycles
  has_many :mesocycles
  has_many :microcycles
  has_many :workouts

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def climb_score_for_period(start_date, end_date, type="all")
    climb_ids = self.attempts.where("completion = 100 AND date > ? AND date < ?", start_date, end_date).map(&:climb_id)
    climbs = self.climbs.where(id: climb_ids)
    if type != "all"
      climbs = climbs.where(climb_type: type)
    end
    best_climbs = climbs.order(grade: :desc).first(10)
    if best_climbs.size > 0
      climb_score = best_climbs.map(&:grade).inject(0){|sum,x| sum + x }.to_f / best_climbs.size
    else
      climb_score = 0
    end
    return climb_score
  end

  def climb_score_difference_for_periods(start_date_1, end_date_1, start_date_2, end_date_2, type="all")
    first_score = self.climb_score_for_period(start_date_1, end_date_1, type)
    second_score = self.climb_score_for_period(start_date_2, end_date_2, type)
    return first_score - second_score
  end

  def profile_graph_data
    graph_data = []
    start_date = DateTime.now - 8.weeks
    for i in 0..3
      end_date = start_date + 2.weeks
      name_string = "#{start_date.strftime('%m/%d/%Y')} - #{end_date.strftime('%m/%d/%Y')}"
      score = self.climb_score_for_period(start_date, end_date)
      graph_data << {'name': name_string,
                     'value': score,
                     'tooltip_value': Climb.convert_score_to_grades(score)}
      start_date = end_date
    end
    return graph_data
  end


  def line_data(start_date, end_date)
    return [{'name': "name 1", 'value': 50},
            {'name': "name 2", 'value': 55},
            {'name': "name 3", 'value': 70},
            {'name': "name 4", 'value': 80}]
  end

  def line_data_test(start_date, end_date)
    return [{'name': "test name 1", 'value': 30},
            {'name': "test name 2", 'value': 40},
            {'name': "test name 3", 'value': 35},
            {'name': "test name 4", 'value': 60}]
  end

  def line_data_string_test(start_date, end_date, prefix)
    line_data_string = ""
    self.line_data_test(start_date, end_date).each_with_index do |point_data, index|
      line_data_string << "data-#{prefix}-name-#{index}='#{point_data[:name]}' data-#{prefix}-value-#{index}='#{point_data[:value]}' ".html_safe
    end
    return line_data_string
  end

end
