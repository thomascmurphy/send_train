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

  def self.campus_score(campus_rungs_string)
    campus_rung_array = []
    campus_score = nil
    if campus_rungs_string.count("-") >= 1
      campus_rung_array = campus_rungs_string.split("-").map(&:to_i).reject { |c| c == 0 }
    elsif campus_rungs_string.count(" ") >= 1
      campus_rung_array = campus_rungs_string.split(" ").map(&:to_i).reject { |c| c == 0 }
    end
    if campus_rung_array.count > 0
      campus_rung_skips = campus_rung_array.each_cons(2).map { |a,b| (b-a).abs }
      top_three_skips = campus_rung_skips.sort.last(3)
      top_three_skips_sum = top_three_skips.inject(0){|sum,x| sum + x }
      total_rungs = campus_rung_skips.inject(0){|sum,x| sum + x }
      campus_score = top_three_skips_sum**2 + total_rungs
    end
    graded_campus_score = campus_score * 1.1 + 36.0
    return graded_campus_score
  end

  def quantify
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
    when ["hold-type", "rest-time", "time", "weight"],
         ["hold-type", "repetitions", "rest-time", "time", "weight"],
         ["hold-size", "hold-type", "rest-time", "time", "weight"],
         ["hold-size", "hold-type", "repetitions", "rest-time", "time", "weight"]
      quantifications = []
      weights = []
      hang_times = []
      hold_size = 1
      hold_size_string = ""
      hold_type = nil
      sibling_performances.group_by(&:rep).each do |rep, performances|
        rest_time = nil
        hang_time = nil
        weight_original = nil
        weight = nil
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
            weight = performance.calculated_value || 0
          when 'time'
            hang_time = performance.value.to_i
          when 'rest-time'
            rest_time = performance.value.to_i
          else
          end
        end
        quantifications << (weight * hang_time * (1 / hold_size))
        weights << weight_original
        hang_times << hang_time
      end
      name = hold_type
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      average_weight = weights.inject{ |sum, el| sum + el }.to_f / weights.size
      average_hang_time = hang_times.inject{ |sum, el| sum + el }.to_f / hang_times.size
      tooltip_value = "#{hold_size_string}#{average_weight.round(2)}#{self.user.default_weight_unit} for #{average_hang_time.round(2)}s"
    when ["repetitions"]
      name = exercise.label
      quantifications = sibling_performances.pluck(:value).map(&:to_i)
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      tooltip_value = "#{quantification.round(2)} reps"
    when ["time"]
      name = exercise.label
      quantifications = sibling_performances.pluck(:value).map(&:to_i)
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      tooltip_value = "#{quantification.round(2)}s"
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
      tooltip_value = Climb.convert_score_to_grades(quantification, self.user.grade_format, climb_type)
    when ["campus-rungs"], ["campus-rungs", "rest-time"], ["campus-rungs", "hold-type", "rest-time"]
      quantifications = []
      campus_rungs = nil
      sibling_performances.group_by(&:rep).each do |rep, performances|
        campus_score = nil
        rest_time = nil
        performances.each do |performance|
          case exercise_metric_type_conversion[performance.workout_metric.exercise_metric.exercise_metric_type_id]
          when 'campus-rungs'
            campus_rungs = performance.value
            campus_score = self.class.campus_score(performance.value)
          else
          end
        end
        quantifications << campus_score
      end
      name = "#{exercise.label} (#{campus_rungs})"
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      tooltip_value = "#{quantification.round(2)}"
    else
      name = nil
      quantification = nil
      tooltip_value = nil
    end
    if name.present? && quantification.present? && tooltip_value.present?
      return {'name': name, 'value': quantification, 'tooltip_value': tooltip_value}
    else
      return nil
    end
  end
end
