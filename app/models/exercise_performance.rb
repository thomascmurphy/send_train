class ExercisePerformance < ActiveRecord::Base
  belongs_to :user
  belongs_to :workout_metric
  belongs_to :event
  after_save :set_calculated_value

  def set_calculated_value
    exercise_metric_type = self.workout_metric.exercise_metric.exercise_metric_type
    if exercise_metric_type.slug == "weight"
      calculated_value = self.user.agnostic_weight(self.value.to_i)
      self.update_column(:calculated_value, calculated_value)
    end
  end

  def self.test_campus_scores
    campus_moves = ["1 2 3",
                    "1 3 4",
                    "1 3 5",
                    "1 4 6",
                    "1 4 7",
                    "1 3 5 7",
                    "1 5 8",
                    "1 5 9",
                    "1 2 3 4 5 6 7 8",
                    "1 2 3 4 5 6 7 8 7 6 5 4 3 2 1",
                    "14",
                    "1 4 7 8 9",
                    "1 2",
                    "1 3",
                    "1 4",
                    "1 5",
                    "1 6",
                    "1 7",
                    "1 5 1"]
    values = []
    campus_moves.each do |campus_move|
      campus_move_score = campus_score(campus_move)
      values << {move: campus_move, value: campus_move_score, grade: Climb.convert_score_to_grades(campus_move_score, "western", "boulder")}
    end
    values
  end

  def self.campus_score(campus_rungs_string, weight_ratio=0)
    campus_rung_array = []
    campus_score = 0
    weight_factor = (weight_ratio.to_f + 1)
    if campus_rungs_string.count("-") >= 1
      campus_rung_array = campus_rungs_string.split("-").map(&:to_i).reject { |c| c == 0 }
    elsif campus_rungs_string.count(" ") >= 1
      campus_rung_array = campus_rungs_string.split(" ").map(&:to_i).reject { |c| c == 0 }
    else
      rung_count = campus_rungs_string.to_i
      laps = (rung_count / 8.0).floor
      up_laps = (laps / 2.0).ceil
      up_leftovers = rung_count % 8 == rung_count % 16 ? rung_count % 8 : 0
      down_laps = (laps / 2.0).floor
      down_leftovers = rung_count % 8 != rung_count % 16 ? rung_count % 8 : 0
      up_count = up_laps * 8 + up_leftovers
      down_count = down_laps * 8 + down_leftovers
      campus_rung_array = (1..up_count).to_a + (up_count-down_count..up_count).to_a.reverse
    end
    if campus_rung_array.count > 0
      campus_rung_skips = campus_rung_array.each_cons(2).map { |a,b| (b < a) ? (b-a).abs * 0.3 : (b-a).abs }
      sorted_skips = campus_rung_skips.sort
      top_skip = sorted_skips.last
      second_top_skip = sorted_skips[-2] || 0
      skip_value = top_skip**1.3 + second_top_skip**1.1
      top_skips_total = sorted_skips.last(2).inject(0){|sum,x| sum + x }
      top_skips_avg = sorted_skips.last(2).inject(0){|sum,x| sum + x } / sorted_skips.last(2).count
      total_rungs = campus_rung_skips.inject(0){|sum,x| sum + x }
      campus_score = skip_value * 2.5 + (total_rungs - top_skips_total)**0.6
    end
    graded_campus_score = weight_factor * campus_score * 4 + 15
    return graded_campus_score
  end

  def self.test_hang_scores
    hangs = [{weight: 0, hang_time: 10, rest_time: 0, hold_size: 2, reps: 1, fingers: 4, angle: 0},
             {weight: 0, hang_time: 10, rest_time: 0, hold_size: 1, reps: 1, fingers: 4, angle: 0},
             {weight: 0, hang_time: 10, rest_time: 0, hold_size: 0.5, reps: 1, fingers: 4, angle: 0},
             {weight: 1, hang_time: 10, rest_time: 0, hold_size: 1, reps: 1, fingers: 4, angle: 0},
             {weight: 0.5, hang_time: 10, rest_time: 0, hold_size: 0.5, reps: 1, fingers: 4, angle: 0},
             {weight: 0, hang_time: 10, rest_time: 0, hold_size: 2, reps: 1, fingers: 4, angle: 10},
             {weight: 0, hang_time: 10, rest_time: 0, hold_size: 2, reps: 1, fingers: 4, angle: 20},
             {weight: 0.3, hang_time: 10, rest_time: 0, hold_size: 2, reps: 1, fingers: 4, angle: 30},
             {weight: 0, hang_time: 10, rest_time: 0, hold_size: 2, reps: 1, fingers: 4, angle: 40}
           ]
    values = []
    hangs.each do |hang|
      hang_score = hang_score(hang[:weight], hang[:hang_time], hang[:rest_time], hang[:hold_size], hang[:reps], hang[:fingers], hang[:angle])
      hang_title = "#{hang[:weight] * 100}% bodyweight for #{hang[:hang_time]} seconds with #{hang[:rest_time]} seconds off on #{hang[:fingers]} finger #{hang[:hold_size]} pads #{hang[:angle]} degrees #{hang[:reps]} times"
      values << {move: hang_title, value: hang_score, grade: Climb.convert_score_to_grades(hang_score, "western", "boulder")}
    end
    values
  end

  def self.hang_score(weight_ratio, hang_time, rest_time, hold_size, reps=1, fingers=4, angle=0)
    #single_hang_score = ((weight_ratio + 1)/1.1)**2.1 * hang_time**0.6 / (hold_size / 2.0)**1.2
    weight_factor = 5*(weight_ratio.to_f + 1)
    hang_time_factor = (hang_time.to_f)**0.7
    hold_size_factor = 1 / (hold_size.to_f + 0.7)**1.1
    fingers_factor = 1 / (0.25 * fingers.to_f)**0.6
    angle_factor = ((angle.to_f + 720)/720)**21
    single_hang_score = weight_factor * hang_time_factor * hold_size_factor * fingers_factor * angle_factor
    rep_multiplier = reps.to_f ** 0.25 / ((rest_time.to_f + 1)**0.2 + 1.2)
    score = 8 * single_hang_score * rep_multiplier - 5
    return score
  end

  def self.test_pullup_scores
    pullups = [{weight: 0, reps: 1},
               {weight: 0, reps: 5},
               {weight: 0, reps: 10},
               {weight: 0, reps: 15},
               {weight: 0.1, reps: 1},
               {weight: 0.2, reps: 1},
               {weight: 0.3, reps: 1},
               {weight: 0.4, reps: 1},
               {weight: 0.5, reps: 1},
               {weight: 1.0, reps: 1}
              ]
    values = []
    pullups.each do |pullup|
      score = pullup_score(pullup[:weight], pullup[:reps])
      title = "#{pullup[:weight] * 100}% bodyweight #{pullup[:reps]} times"
      values << {move: title, value: score, grade: Climb.convert_score_to_grades(score, "western", "boulder")}
    end
    values
  end

  def self.pullup_score(weight_ratio, reps)
    weight_factor = (6 * weight_ratio.to_f + 2)**1.1
    rep_multiplier = reps.to_f ** 0.45
    score = 10 * weight_factor * rep_multiplier + 5
  end

  def quantify(normalize=false)
    exercise_metric_type_conversion = {}
    ExerciseMetricType.all.each do |exercise_metric_type|
      exercise_metric_type_conversion[exercise_metric_type.id] = exercise_metric_type.slug
    end
    exercise = self.workout_metric.exercise_metric.exercise
    workout_exercise = self.workout_metric.workout_exercise
    workout_metric_ids = WorkoutMetric.where(workout_exercise_id: workout_exercise.id).pluck(:id)
    sibling_performances = ExercisePerformance.where(event_id: self.event_id, workout_metric_id: workout_metric_ids)
    exercise_metric_types = exercise.exercise_metrics.pluck(:exercise_metric_type_id).map{|type_id| exercise_metric_type_conversion[type_id]}
    case exercise_metric_types.uniq.sort
    when ["hold-size", "hold-type", "time", "weight"],
         ["hold-type", "rest-time", "time", "weight"],
         ["hold-type", "repetitions", "rest-time", "time", "weight"],
         ["hold-size", "hold-type", "rest-time", "time", "weight"],
         ["hold-size", "hold-type", "repetitions", "rest-time", "time", "weight"]
      quantifications = []
      weights = []
      hang_times = []
      hold_size = 2
      hold_size_string = ""
      hold_type = nil
      sibling_performances.group_by(&:rep).each do |rep, performances|
        rest_time = nil
        hang_time = nil
        weight_original = nil
        weight = nil
        reps = 1
        hang_score = nil
        performances.each do |performance|
          case exercise_metric_type_conversion[performance.workout_metric.exercise_metric.exercise_metric_type_id]
          when 'hold-size'
            if performance.value.present?
              hold_size = performance.value.to_f
              hold_size_string = "#{ExerciseMetricOption.pretty_hold_size(performance.value)} with "
            end
          when 'hold-type'
            hold_type = performance.value
          when 'weight'
            weight_original = performance.value.to_i
            weight = performance.calculated_value || 0.0
          when 'time'
            hang_time = performance.value.to_i
          when 'rest-time'
            rest_time = performance.value.to_i
          when 'repetitions'
            reps = performance.value.to_i
          else
          end
        end
        if hold_type.present? && (hold_type.downcase.include?("one finger") || hold_type.downcase.include?("mono") || hold_type.downcase.include?("1 finger"))
          fingers = 1
        elsif hold_type.present? && (hold_type.downcase.include?("two finger") || hold_type.downcase.include?("2 finger"))
          fingers = 2
        elsif hold_type.present? && (hold_type.downcase.include?("three finger") || hold_type.downcase.include?("3 finger"))
          fingers = 3
        else
          fingers = 4
        end
        if hold_type.present? && hold_type.downcase.include?("sloper")
          angle = 30
        elsif hold_type.present? && hold_type.downcase.include?("pinch")
          angle = 30
        else
          angle = 0
        end
        if normalize.present?
          hang_score = self.class.hang_score(weight, hang_time, rest_time, hold_size, reps, fingers, angle)
        else
          hang_score = (weight * hang_time * (1 / hold_size))
        end
        quantifications << hang_score
        weights << weight_original
        hang_times << hang_time
      end
      name = hold_type
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      average_weight = weights.inject{ |sum, el| sum + el }.to_f / weights.size
      average_hang_time = hang_times.inject{ |sum, el| sum + el }.to_f / hang_times.size
      tooltip_value = "#{hold_size_string}#{average_weight.round(2)}#{self.user.default_weight_unit} for #{average_hang_time.round(2)}s"
      climb_grade = Climb.convert_score_to_grades(quantification, "western", "boulder")
      category = workout_exercise.pretty_type
    when ["repetitions", "weight"]
      name = workout_exercise.label.present? ? workout_exercise.label : "#{exercise.label}"
      quantifications = []
      weights = []
      rep_counts = []
      sibling_performances.group_by(&:rep).each do |rep, performances|
        score = nil
        reps = nil
        weight = nil
        weight_original = nil
        performances.each do |performance|
          case exercise_metric_type_conversion[performance.workout_metric.exercise_metric.exercise_metric_type_id]
          when 'repetitions'
            reps = performance.value
          when 'weight'
            weight_original = performance.value.to_i
            weight = performance.calculated_value || 0.0
          else
          end
        end
        score = self.class.pullup_score(weight, reps)
        quantifications << score
        weights << weight_original
        rep_counts << reps
      end
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      average_reps = rep_counts.inject{ |sum, el| sum + el }.to_f / rep_counts.size
      average_weight = weights.inject{ |sum, el| sum + el }.to_f / weights.size
      tooltip_value = "#{average_reps.round(2)} with #{average_weight.round(2)}#{self.user.default_weight_unit}"
      climb_grade = Climb.convert_score_to_grades(quantification, "western", "boulder")
      category = workout_exercise.pretty_type
    when ["repetitions"]
      name = exercise.label
      quantifications = sibling_performances.pluck(:value).map(&:to_i)
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      tooltip_value = "#{quantification.round(2)} reps"
      climb_grade = ""
      category = workout_exercise.pretty_type
    when ["time"]
      name = exercise.label
      quantifications = sibling_performances.pluck(:value).map(&:to_i)
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      tooltip_value = "#{quantification.round(2)}s"
      climb_grade = ""
      category = workout_exercise.pretty_type
    when ["boulder-grade", "completion"], ["sport-grade", "completion"]
      climb_type = nil
      if exercise_metric_types.uniq.sort == ["boulder-grade", "completion"]
        climb_type = "boulder"
      elsif exercise_metric_types.uniq.sort == ["sport-grade", "completion"]
        climb_type = "sport"
      end
      name = exercise.label
      completions = []
      average_grades = []
      quantifications = []
      sibling_performances.group_by(&:rep).each do |rep, performances|
        completion = 1
        climb_score = 0
        climb_count = 0
        performances.each do |performance|
          case exercise_metric_type_conversion[performance.workout_metric.exercise_metric.exercise_metric_type_id]
          when 'boulder-grade', 'sport-grade'
            climb_score += performance.value.to_i
            climb_count += 1
          else
            completion = performance.value.to_i
          end
        end
        average_grade = climb_score.to_f / climb_count
        average_grades << average_grade
        completions << completion
        quantifications << (average_grade * (completion.to_f / 100))
      end
      total_average_grade = average_grades.inject{ |sum, el| sum + el }.to_f / average_grades.size
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      climb_string = Climb.convert_score_to_grades(total_average_grade, self.user.grade_format, climb_type)
      completion_string = "#{completions.inject{ |sum, el| sum + el }.to_f / completions.size}%"
      tooltip_value = "#{climb_string} (#{completion_string} completion)"
      climb_grade = climb_string
      category = workout_exercise.pretty_type
    when ["boulder-grade"], ["sport-grade"]
      climb_type = nil
      if exercise_metric_types.uniq.sort == ["boulder-grade"]
        climb_type = "boulder"
      elsif exercise_metric_types.uniq.sort == ["sport-grade"]
        climb_type = "sport"
      end
      name = exercise.label
      quantifications = sibling_performances.pluck(:value).map(&:to_i)
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      climb_string = Climb.convert_score_to_grades(quantification, self.user.grade_format, climb_type)
      tooltip_value = climb_string
      climb_grade = climb_string
      category = workout_exercise.pretty_type
    when ["campus-rungs"],
         ["campus-rungs", "rest-time"],
         ["campus-rungs", "hold-type"],
         ["campus-rungs", "hold-type", "rest-time"]
      quantifications = []
      campus_rungs = nil
      name = workout_exercise.label.present? ? workout_exercise.label : "#{exercise.label} (#{campus_rungs})"
      if name.present? && (name.downcase.include?("foot on") || name.downcase.include?("feet on"))
        weight_ratio = -0.5
      else
        weight_ratio = 0
      end
      sibling_performances.group_by(&:rep).each do |rep, performances|
        campus_score = nil
        rest_time = nil
        performances.each do |performance|
          case exercise_metric_type_conversion[performance.workout_metric.exercise_metric.exercise_metric_type_id]
          when 'campus-rungs'
            campus_rungs = performance.value
            campus_score = self.class.campus_score(performance.value, weight_ratio)
          else
          end
        end

        quantifications << campus_score
      end
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      tooltip_value = "#{campus_rungs}"
      climb_grade = Climb.convert_score_to_grades(quantification, "western", "boulder")
      category = workout_exercise.pretty_type
    else
      name = nil
      quantification = nil
      tooltip_value = nil
      climb_grade = nil
      category = nil
    end
    if name.present? && quantification.present? && tooltip_value.present?
      return {'name': name, 'value': quantification, 'tooltip_value': tooltip_value, 'climb_grade': climb_grade, 'category': category}
    else
      return nil
    end
  end
end
