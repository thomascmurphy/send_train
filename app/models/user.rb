class User < ActiveRecord::Base
  has_many :climbs, dependent: :destroy
  has_many :attempts, through: :climbs
  has_many :events, dependent: :destroy
  has_many :macrocycles
  has_many :mesocycles, dependent: :destroy
  has_many :microcycles, dependent: :destroy
  has_many :workouts
  has_many :exercises
  has_many :exercise_metrics, through: :exercises
  has_many :exercise_performances, dependent: :destroy
  has_many :coaches, class_name: 'UserCoach', foreign_key: 'user_id', dependent: :destroy
  has_many :students, class_name: 'UserCoach', foreign_key: 'coach_id', dependent: :destroy
  has_many :goals
  after_create :seed_exercises

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def seed_exercises
    deadhang = self.exercises.create(
      label: "Deadhang",
      exercise_type: "strength",
      description: "Hang",
      reference_id: 1
    )
    deadhang_metric_hold = deadhang.exercise_metrics.create(
      label: "Hold",
      exercise_metric_type_id: ExerciseMetricType::HOLD_TYPE_ID
    )
    hold_options = deadhang_metric_hold.exercise_metric_options.create([
      {label: "Crimp", value: "Crimp"},
      {label: "Sloper", value: "Sloper"},
      {label: "Pinch", value: "Pinch"},
      {label: "Front Two Fingers", value: "Front Two Fingers"},
      {label: "Middle Two Fingers", value: "Middle Two Fingers"},
      {label: "Back Two Fingers", value: "Back Two Fingers"},
      {label: "Front Three Fingers", value: "Front Three Fingers"}
    ])
    deadhang_metric_hold_size = deadhang.exercise_metrics.create(
      label: "Hold Size",
      exercise_metric_type_id: ExerciseMetricType::HOLD_SIZE_ID
    )
    deadhang_metric_weight = deadhang.exercise_metrics.create(
      label: "Weight",
      exercise_metric_type_id: ExerciseMetricType::WEIGHT_ID
    )
    deadhang_metric_hang_time = deadhang.exercise_metrics.create(
      label: "Hang Time",
      exercise_metric_type_id: ExerciseMetricType::TIME_ID
    )
    deadhang_metric_rest_time = deadhang.exercise_metrics.create(
      label: "Rest Time",
      exercise_metric_type_id: ExerciseMetricType::REST_TIME_ID
    )
    deadhang_metric_reps = deadhang.exercise_metrics.create(
      label: "Reps",
      exercise_metric_type_id: ExerciseMetricType::REPETITIONS_ID
    )

    campus = self.exercises.create(
      label: "Campus",
      exercise_type: "power",
      description: "Campus moves",
      reference_id: 2
    )
    campus_metric_campus_rungs = campus.exercise_metrics.create(
      label: "Rungs",
      exercise_metric_type_id: ExerciseMetricType::CAMPUS_RUNGS_ID
    )
    campus_metric_rung_size = campus.exercise_metrics.create(
      label: "Rung Size",
      exercise_metric_type_id: ExerciseMetricType::HOLD_TYPE_ID
    )
    rung_options = campus_metric_rung_size.exercise_metric_options.create([
      {label: "Large Edge", value: "Large Edge"},
      {label: "Medium Edge", value: "Medium Edge"},
      {label: "Small Edge", value: "Small Edge"}
    ])
    campus_metric_rest_time = campus.exercise_metrics.create(
      label: "Rest Time",
      exercise_metric_type_id: ExerciseMetricType::REST_TIME_ID
    )

    rest = self.exercises.create(
      label: "Rest",
      exercise_type: "",
      description: "Rest time in between sets",
      reference_id: 3
    )
    rest_metric_rest_time = rest.exercise_metrics.create(
      label: "Rest Time",
      exercise_metric_type_id: ExerciseMetricType::REST_TIME_ID
    )

    four_by_four = self.exercises.create(
      label: "4x4",
      exercise_type: "powerendurance",
      description: "Four by four",
      reference_id: 4
    )
    four_by_four_metric_climb_1 = four_by_four.exercise_metrics.create(
      label: "Climb 1",
      exercise_metric_type_id: ExerciseMetricType::BOULDER_GRADE_ID
    )
    four_by_four_metric_climb_2 = four_by_four.exercise_metrics.create(
      label: "Climb 2",
      exercise_metric_type_id: ExerciseMetricType::BOULDER_GRADE_ID
    )
    four_by_four_metric_climb_3 = four_by_four.exercise_metrics.create(
      label: "Climb 3",
      exercise_metric_type_id: ExerciseMetricType::BOULDER_GRADE_ID
    )
    four_by_four_metric_climb_4 = four_by_four.exercise_metrics.create(
      label: "Climb 4",
      exercise_metric_type_id: ExerciseMetricType::BOULDER_GRADE_ID
    )
    four_by_four_metric_completion = four_by_four.exercise_metrics.create(
      label: "Completion",
      exercise_metric_type_id: ExerciseMetricType::COMPLETION_ID
    )

    hangboard_workout = self.workouts.create(
      label: "Hangboard Repeaters",
      workout_type: "strength",
      description: "Repeater hangboard workout",
      reference_id: 1
    )
    holds = ["Sloper", "Pinch", "Crimp", "Front Two Fingers", "Middle Two Fingers", "Front Three Fingers"]
    holds.each_with_index do |hold, hold_index|
      hangboard_workout_exercise = hangboard_workout.workout_exercises.create(
        exercise: deadhang,
        order_in_workout: hold_index*2,
        reps: 3
      )
      hangboard_workout_metrics = hangboard_workout_exercise.workout_metrics.create([
        {exercise_metric: deadhang_metric_hold, value: hold},
        {exercise_metric: deadhang_metric_hold_size, value: nil},
        {exercise_metric: deadhang_metric_weight, value: 0},
        {exercise_metric: deadhang_metric_hang_time, value: 7},
        {exercise_metric: deadhang_metric_rest_time, value: 3},
        {exercise_metric: deadhang_metric_reps, value: 6}
      ])
      if hold_index < holds.length - 1
        hangboard_workout_exercise_rest = hangboard_workout.workout_exercises.create(
          exercise: rest,
          order_in_workout: hold_index*2 + 1,
          reps: 1
        )
        hangboard_workout_metric_rest = hangboard_workout_exercise_rest.workout_metrics.create(
          exercise_metric: rest_metric_rest_time,
          value: 120
        )
      end
    end

    campus_workout = self.workouts.create(
      label: "Campusboard",
      workout_type: "power",
      description: "General campusboard workout",
      reference_id: 2
    )
    campus_moves = ["1 3 5", "1 6"]
    campus_moves.each_with_index do |campus_move, campus_index|
      campus_workout_exercise = campus_workout.workout_exercises.create(
        exercise: campus,
        order_in_workout: campus_index,
        reps: 3
      )
      campus_workout_metrics = campus_workout_exercise.workout_metrics.create([
        {exercise_metric: campus_metric_campus_rungs, value: campus_move},
        {exercise_metric: campus_metric_rung_size, value: "Large Edge"},
        {exercise_metric: campus_metric_rest_time, value: 60}
      ])
    end

    four_by_four_workout = self.workouts.create(
      label: "4x4",
      workout_type: "powerendurance",
      description: "4x4 workout",
      reference_id: 3
    )
    four_by_four_workout_exercise = four_by_four_workout.workout_exercises.create(
      exercise: four_by_four,
      order_in_workout: 1,
      reps: 4
    )
    four_by_four_workout_metrics = four_by_four_workout_exercise.workout_metrics.create([
      {exercise_metric: four_by_four_metric_climb_1, value: nil},
      {exercise_metric: four_by_four_metric_climb_2, value: nil},
      {exercise_metric: four_by_four_metric_climb_3, value: nil},
      {exercise_metric: four_by_four_metric_climb_4, value: nil},
      {exercise_metric: four_by_four_metric_completion, value: 100}
    ])

    basic_plan = self.macrocycles.create(
      label: "Periodized Training Plan",
      reference_id: 1
    )
    hangboard_days = [2,4, 9,11, 16,18, 23,25]
    hangboard_days.each do |hangboard_day|
      basic_macrocycle_workout = basic_plan.macrocycle_workouts.create(
        workout: hangboard_workout,
        order_in_day: 0,
        day_in_cycle: hangboard_day
      )
    end
    campus_days = [30,32, 37,39, 44,46]
    campus_days.each do |campus_day|
      basic_macrocycle_workout = basic_plan.macrocycle_workouts.create(
        workout: campus_workout,
        order_in_day: 0,
        day_in_cycle: campus_day
      )
    end
    four_by_four_days = [51,53, 58,60, 65,67]
    four_by_four_days.each do |four_by_four_day|
      basic_macrocycle_workout = basic_plan.macrocycle_workouts.create(
        workout: four_by_four_workout,
        order_in_day: 0,
        day_in_cycle: four_by_four_day
      )
    end

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
      "We also created a few basic workouts to give you an idea of how to structure your own."
    when 3
      "Finally, we set up a basic training plan with these workouts to give you a starting point."
    when 4
      "With this plan template or any that you create, you can schedule a set of events based on this template and start training!"
    when 5
      "You can also track your climbing progress so that we can try to determine the effectiveness of each workout that you do."
    when 6
      "Remember why you train: record your goals, break them down into subgoals, and tick them off as you progress."
    when 7
      "Thanks so much for taking the tour! I hope this is a helpful tool for everyone."
    else
      nil
    end
  end

  def climb_score_at_date(end_date, type="all")
    climb_ids = self.attempts.where("completion = 100 AND date < ?", end_date).map(&:climb_id)
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

  def climb_score_difference_at_dates(end_date_1, end_date_2, type="all")
    first_score = self.climb_score_at_date(end_date_1, type)
    second_score = self.climb_score_at_date(end_date_2, type)
    return first_score - second_score
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

  def climb_graph_data_for_dates(dates)
    graph_data = []
    dates.each do |date|
      name_string = "#{date.strftime('%b %d, %Y')}"
      score = self.climb_score_at_date(date)
      graph_data << {'name': name_string,
                     'value': score,
                     'tooltip_value': Climb.convert_score_to_grades(score, self.grade_format)}
    end
    return graph_data
  end

  def climb_graph_data
    dates = [DateTime.now - 6.weeks,
             DateTime.now - 4.weeks,
             DateTime.now - 2.weeks,
             DateTime.now]
    return self.climb_graph_data_for_dates(dates)
  end

  # def profile_graph_data
  #   graph_data = []
  #   start_date = DateTime.now - 8.weeks
  #   for i in 0..3
  #     end_date = start_date + 2.weeks
  #     name_string = "#{start_date.strftime('%m/%d/%Y')} - #{end_date.strftime('%m/%d/%Y')}"
  #     score = self.climb_score_for_period(start_date, end_date)
  #     graph_data << {'name': name_string,
  #                    'value': score,
  #                    'tooltip_value': Climb.convert_score_to_grades(score, self.grade_format)}
  #     start_date = end_date
  #   end
  #   return graph_data
  # end


  def should_show_climb_data?
    should_show = false
    climb_count = self.climbs.count
    oldest_attempt = self.attempts.order(date: :asc).first
    if oldest_attempt.present?
      if self.id == 1 || (climb_count > 20 && oldest_attempt.date < DateTime.now - 6.weeks)
        should_show = true
      end
    end
    return should_show
  end

  def should_show_workout_data?
    should_show = false
    completed_macrocycles_count = self.events.where.not(macrocycle_id: nil).count
    oldest_completed = self.events.where.not(macrocycle_id: nil).order(start_date: :asc).first
    if oldest_completed.present?
      if completed_macrocycles_count > 2 && oldest_completed.start_date < DateTime.now - 6.weeks
        should_show = true
      end
    end
    return should_show
  end

  def agnostic_weight(weight)
    agnostic_weight = weight
    user_weight = self.weight || 0
    if self.weight_unit == "lb"
      user_weight = user_weight * 0.453592
    end
    if self.default_weight_unit == "lb"
      agnostic_weight = weight * 0.453592
    end
    return user_weight + agnostic_weight
  end

  def smart_name
    if self.first_name.present? || self.last_name.present?
      return "#{self.first_name} #{self.last_name}"
    else
      return self.email
    end
  end

end
