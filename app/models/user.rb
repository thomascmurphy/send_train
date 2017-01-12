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
  has_many :followers, class_name: 'UserFollower', foreign_key: 'user_id', dependent: :destroy
  has_many :following, class_name: 'UserFollower', foreign_key: 'follower_id', dependent: :destroy
  has_many :goals
  has_many :sent_messages, class_name: 'Message', foreign_key: 'user_id', dependent: :destroy
  has_many :votes
  has_many :messages, as: :messageable
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

  def climb_score_at_date(end_date)
    climb_ids = self.attempts.where("completion = 100 AND date <= ?", end_date).map(&:climb_id)
    climbs = self.climbs.where(id: climb_ids)
    boulders = climbs.where(climb_type: "boulder")
    ropes = climbs.where(climb_type: ["sport", "trad"])
    best_climbs = climbs.order(grade: :desc).first(10)
    if best_climbs.size > 0
      climb_score = best_climbs.map(&:grade).inject(0){|sum,x| sum + x }.to_f / best_climbs.size
    else
      climb_score = 0
    end

    best_boulders = boulders.order(grade: :desc).first(10)
    if best_boulders.size > 0
      boulder_score = best_boulders.map(&:grade).inject(0){|sum,x| sum + x }.to_f / best_boulders.size
    else
      boulder_score = nil
    end

    best_ropes = ropes.order(grade: :desc).first(10)
    if best_ropes.size > 0
      rope_score = best_ropes.map(&:grade).inject(0){|sum,x| sum + x }.to_f / best_ropes.size
    else
      rope_score = nil
    end

    return {all: climb_score, boulder: boulder_score, sport: rope_score}
  end

  def climb_score_difference_at_dates(end_date_1, end_date_2, type="all")
    first_score = self.climb_score_at_date(end_date_1).with_indifferent_access[type]
    second_score = self.climb_score_at_date(end_date_2).with_indifferent_access[type]
    return first_score - second_score
  end

  def climb_score_for_period(start_date, end_date)
    climb_ids = self.attempts.where("completion = 100 AND date >= ? AND date <= ?", start_date, end_date).map(&:climb_id)
    climbs = self.climbs.where(id: climb_ids)
    boulders = climbs.where(climb_type: "boulder")
    ropes = climbs.where(climb_type: ["sport", "trad"])
    best_climbs = climbs.order(grade: :desc).first(10)
    if best_climbs.size > 0
      climb_score = best_climbs.map(&:grade).inject(0){|sum,x| sum + x }.to_f / best_climbs.size
    else
      climb_score = 0
    end

    best_boulders = boulders.order(grade: :desc).first(10)
    if best_boulders.size > 0
      boulder_score = best_boulders.map(&:grade).inject(0){|sum,x| sum + x }.to_f / best_boulders.size
    else
      boulder_score = nil
    end

    best_ropes = ropes.order(grade: :desc).first(10)
    if best_ropes.size > 0
      rope_score = best_ropes.map(&:grade).inject(0){|sum,x| sum + x }.to_f / best_ropes.size
    else
      rope_score = nil
    end

    return {all: climb_score, boulder: boulder_score, sport: rope_score}
  end

  def climb_score_difference_for_periods(start_date_1, end_date_1, start_date_2, end_date_2, type="all")
    first_score = self.climb_score_for_period(start_date_1, end_date_1).with_indifferent_access[type]
    second_score = self.climb_score_for_period(start_date_2, end_date_2).with_indifferent_access[type]
    return first_score - second_score
  end

  def climb_graph_data_for_dates(dates)
    graph_data = []
    dates.each do |date|
      name_string = "#{date.strftime('%b %d, %Y')}"
      scores = self.climb_score_at_date(date.end_of_day)
      if scores[:boulder].present? && scores[:sport].present?
        grade_string = "#{Climb.convert_score_to_grades(scores[:boulder], self.grade_format, 'boulder')} / #{Climb.convert_score_to_grades(scores[:sport], self.grade_format, 'sport')}"
      elsif scores[:boulder].present?
        grade_string = Climb.convert_score_to_grades(scores[:boulder], self.grade_format, 'boulder')
      elsif scores[:sport].present?
        grade_string = Climb.convert_score_to_grades(scores[:sport], self.grade_format, 'sport')
      else
        grade_string = Climb.convert_score_to_grades(scores[:all], self.grade_format)
      end
      grade_strings =
      graph_data << {'name': name_string,
                     'value': scores[:all],
                     'tooltip_value': grade_string}
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

  def smart_name(display_email=false)
    if self.handle.present?
      return self.handle
    elsif self.first_name.present? || self.last_name.present?
      return "#{self.first_name} #{self.last_name}"
    elsif display_email.present?
      return self.email
    else
      return "User #{self.id}"
    end
  end

  def my_users
    user_ids = UserFollower.where(follower_id: self.id).pluck(:user_id)
    if user_ids.present?
      users = User.where(id: user_ids).sort_by(&:current_sign_in_at).reverse
    else
      users = nil
    end
    users
  end

  def my_followers
    user_ids = UserFollower.where(user_id: self.id).pluck(:follower_id)
    if user_ids.present?
      users = User.where(id: user_ids).sort_by(&:current_sign_in_at).reverse
    else
      users = nil
    end
    users
  end

  def is_following(user_id)
    user_id.present? && self.following.where(user_id: user_id).present?
  end

  def follower_count
    UserFollower.where(user_id: self.id).count
  end

  def workout_count
    self.workouts.count
  end

  def parent_goals
    self.goals.where(parent_goal_id: nil)
  end

  def dashboard_activity
    activity = []

    my_user_ids = self.my_users.present? ? self.my_users.map{|x| x.id} : []
    my_exercise_ids = self.exercises.pluck(:id)
    my_workout_ids = self.workouts.pluck(:id)
    my_macrocycle_ids = self.macrocycles.pluck(:id)
    my_goal_ids = self.goals.pluck(:id)

    followed_user_exercise_activity = Exercise.where(user_id: my_user_ids, created_at: DateTime.now-7.days..DateTime.now.end_of_day)
    followed_user_workout_activity = Workout.where(user_id: my_user_ids, created_at: DateTime.now-7.days..DateTime.now.end_of_day)
    followed_user_macrocycle_activity = Macrocycle.where(user_id: my_user_ids, created_at: DateTime.now-7.days..DateTime.now.end_of_day)

    voted_climb_ids = self.votes.where(voteable_type: "Attempt").pluck(:voteable_id)
    #dunno if I want to keep these here
    voted_climb_ids = []
    my_user_climb_ids = Climb.where(user_id: my_user_ids).pluck(:id)
    user_new_climbs = Attempt.where(completion: 100, climb_id: my_user_climb_ids).where.not(id: voted_climb_ids)

    user_achieved_goals = Goal.where(completed: true, updated_at: DateTime.now-7.days..DateTime.now.end_of_day, user_id: my_user_ids)

    follower_activity = UserFollower.where(user_id: self.id, created_at: DateTime.now-7.days..DateTime.now.end_of_day)

    my_daily_events = self.events.where("start_date <= ? AND end_date >= ?", DateTime.now.end_of_day, DateTime.now.beginning_of_day).where.not(workout_id: nil, completed: true).order(start_date: :asc)
    daily_event_count = my_daily_events.count

    my_message_ids = self.sent_messages.pluck(:id)
    replies = Message.where(parent_message_id: my_message_ids).where(read: false)
    direct_messages = self.messages.where(parent_message_id: nil, read: false)
    new_message_count = replies.length + direct_messages.length

    new_exercise_votes = Vote.where.not(user_id: self.id).where(voteable_type: "Exercise", voteable_id: my_exercise_ids, updated_at: DateTime.now-7.days..DateTime.now.end_of_day, value: 1).group(:voteable_id).count.sort_by { |id, votes| votes }.reverse.to_h
    new_workout_votes = Vote.where.not(user_id: self.id).where(voteable_type: "Workout", voteable_id: my_workout_ids, updated_at: DateTime.now-7.days..DateTime.now.end_of_day, value: 1).group(:voteable_id).count.sort_by { |id, votes| votes }.reverse.to_h
    new_macrocycle_votes = Vote.where.not(user_id: self.id).where(voteable_type: "Macrocycle", voteable_id: my_macrocycle_ids, updated_at: DateTime.now-7.days..DateTime.now.end_of_day, value: 1).group(:voteable_id).count.sort_by { |id, votes| votes }.reverse.to_h
    new_goal_votes = Vote.where.not(user_id: self.id).where(voteable_type: "Goal", voteable_id: my_goal_ids, updated_at: DateTime.now-7.days..DateTime.now.end_of_day, value: 1).group(:voteable_id).count.sort_by { |id, votes| votes }.reverse.to_h




    followed_user_exercise_activity.each do |exercise|
      activity << {label: "New Exercise",
                   description: "#{exercise.user.smart_name} added a new exercise.",
                   item: exercise,
                   date: exercise.created_at}
    end

    followed_user_workout_activity.each do |workout|
      activity << {label: "New Workout",
                   description: "#{workout.user.smart_name} added a new workout.",
                   item: workout,
                   date: workout.created_at}
    end

    followed_user_macrocycle_activity.each do |macrocycle|
      activity << {label: "New Plan Template",
                   description: "#{macrocycle.user.smart_name} added a new plan template.",
                   item: macrocycle,
                   date: macrocycle.created_at}
    end

    user_new_climbs.each do |attempt|
      activity << {label: "Sendage!",
                   description: "#{attempt.climb.user.smart_name} has sent #{attempt.climb.name}.",
                   item: attempt,
                   date: attempt.created_at,
                   custom_link: "/community/users/#{attempt.climb.user.id}"}
    end

    user_achieved_goals.each do |goal|
      activity << {label: "Goal Achieved!",
                   description: "#{goal.user.smart_name} has completed their goal: \"#{goal.label}\".",
                   item: goal,
                   date: goal.updated_at,
                   custom_link: "/community/users/#{goal.user.id}"}
    end

    follower_activity.each do |user_follower|
      activity << {label: "New Follower",
                   description: "#{user_follower.follower.smart_name} is now following you.",
                   item: nil,
                   date: user_follower.created_at,
                   disable_votes: true,
                   custom_link: "/community/users/#{user_follower.follower.id}"}
    end

    activity = activity.sort_by{|x| x[:date]}.reverse

    if new_exercise_votes.present? || new_workout_votes.present? || new_macrocycle_votes.present? || new_goal_votes.present?
      combined_votes = new_exercise_votes.map{|id, votes| {type: "Exercise", id: id, votes: votes}} +
                       new_workout_votes.map{|id, votes| {type: "Workout", id: id, votes: votes}} +
                       new_macrocycle_votes.map{|id, votes| {type: "Macrocycle", id: id, votes: votes}} +
                       new_goal_votes.map{|id, votes| {type: "Goal", id: id, votes: votes}}
      top_voted = combined_votes.sort_by{|x| x[:votes]}.reverse[0..4]
      description = "You have gotten some praise in the last week:<ul>"
      top_voted.each_with_index do |voted_item, index|
        item_klass = Object.const_get voted_item[:type]
        item = item_klass.find(voted_item[:id])
        description << "<li>#{item.label}: #{ActionController::Base.helpers.pluralize(voted_item[:votes], 'like')}"
      end
      description << "</ul>"
      activity.unshift({label: "New Praise",
                        description: description,
                        item: nil,
                        date: DateTime.now})
    end

    if new_message_count > 0
      activity.unshift({label: "New Messages",
                        description: "You have #{ActionController::Base.helpers.pluralize(new_message_count, 'new message')}",
                        item: nil,
                        date: DateTime.now,
                        custom_link: "/community"})
    end

    if my_daily_events.present?
      activity.unshift({label: "Today's Workouts",
                        description: "You have #{ActionController::Base.helpers.pluralize(daily_event_count, 'workout')} on the schedule today.",
                        item: nil,
                        date: DateTime.now,
                        custom_link: "/events"})
    end

    activity[0..11]

  end

  def create_mountain_project_integration(login)
    require 'mountain_project/request'
    mountain_project = MountainProject::Request.new
    if login.present?
      user = mountain_project.get_user_by_email(login)
      user_id = user["id"].to_i if user["id"].present?
      if user_id.present?
        self.mountain_project_user_id = user_id
        self.handle = user["name"] if self.handle.blank?
        self.save
        return user_id
      end
    end
    return false
  end

  def sync_mountain_project_climbs
    require 'mountain_project/request'
    mountain_project = MountainProject::Request.new
    if self.mountain_project_user_id.present?
      ticks = mountain_project.get_ticks(self.mountain_project_user_id)
      if ticks["ticks"].present?
        climb_ids = ticks["ticks"].map{|x| x["routeId"]}
        if climb_ids.present?
          climbs = mountain_project.get_routes(climb_ids)
          if climbs["routes"].present?
            climbs["routes"].each do |route|
              climb = Climb.find_or_initialize_by(mountain_project_id: route["id"].to_i, user_id: self.id)
              if climb.new_record?
                climb = climb.from_mountain_project(route)
                climb.save
              end
              tick = ticks["ticks"].select{|x| x["routeId"] == route["id"].to_i}.first
              attempt = Attempt.find_or_initialize_by(climb_id: climb.id, date: DateTime.strptime(tick["date"], "%Y-%m-%d"))
              if attempt.new_record?
                attempt = attempt.from_mountain_project(tick)
                attempt.save
              end
            end
            return true
          end
        end
      end
    end
    return false
  end

end
