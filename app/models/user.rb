class User < ActiveRecord::Base
  has_many :climbs, dependent: :destroy
  has_many :attempts, through: :climbs
  has_many :events, dependent: :destroy
  has_many :macrocycles
  has_many :mesocycles, dependent: :destroy
  has_many :microcycles, dependent: :destroy
  has_many :workouts
  has_many :exercises
  has_many :exercise_metrics
  after_create :seed_exercises

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def seed_exercises
    deadhang = self.exercises.create(
      label: "Deadhang",
      exercise_type: "strength",
      description: "Hang"
    )
    deadhang_metric_hold = deadhang.exercise_metrics.create(
      label: "Hold",
      exercise_metric_type_id: 5
    )
    hold_options = deadhang_metric_hold.exercise_metric_options.create([
      {label: "Crimp", value: "crimp"},
      {label: "Sloper", value: "sloper"},
      {label: "Pinch", value: "pinch"},
      {label: "Front Two Fingers", value: "front-two-fingers"},
      {label: "Middle Two Fingers", value: "middle-two-fingers"},
      {label: "Back Two Fingers", value: "back-two-fingers"},
      {label: "Front Three Fingers", value: "front-three-fingers"}
    ])
    deadhang_metric_weight = deadhang.exercise_metrics.create(
      label: "Weight",
      exercise_metric_type_id: 1
    )
    deadhang_metric_hang_time = deadhang.exercise_metrics.create(
      label: "Hang Time",
      exercise_metric_type_id: 3
    )
    deadhang_metric_rest_time = deadhang.exercise_metrics.create(
      label: "Rest Time",
      exercise_metric_type_id: 3
    )

    campus = self.exercises.create(
      label: "Campus",
      exercise_type: "power",
      description: "Campus moves"
    )
    campus_metric_campus_rungs = campus.exercise_metrics.create(
      label: "Rungs",
      exercise_metric_type_id: 4
    )
    campus_metric_rest_time = campus.exercise_metrics.create(
      label: "Rest Time",
      exercise_metric_type_id: 3
    )

    rest = self.exercises.create(
      label: "Rest",
      exercise_type: "",
      description: "Rest time in between sets"
    )
    rest_metric_rest_time = rest.exercise_metrics.create(
      label: "Rest Time",
      exercise_metric_type_id: 3
    )
  end

  def advance_onboarding
    self.onboarding_step += 1
    self.save
  end

  def onboarding_message
    case self.onboarding_step
    when 0
      "You can personalize your account by setting some of these preferences."
    when 1
      "We've added a few common exercises to get you started, you can use these as a guide for additional exercises."
    when 2
      "You can use these exercises to build workouts such as a hangboard or campusboard routine."
    when 3
      "You can create a long-term plan by arranging these workouts onto specific days."
    when 4
      "After you have a plan template created, you can schedule a set of events based on this template and start training!"
    when 5
      "You can also track your climbing progress so that we can try to determine the effectiveness of each individual workout."
    when 6
      "Thanks so much for taking the tour! I hope this is a helpful tool for everyone."
    else
      nil
    end
  end

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
                     'tooltip_value': Climb.convert_score_to_grades(score, self.grade_format)}
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
