class Climb < ActiveRecord::Base
  belongs_to :user
  has_many :attempts

  def redpointed
    successful_attempts = self.attempts.where(completion: 100).order(date: :desc)
    redpointed_text = "Open Project"
    if successful_attempts.present?
      if successful_attempts.where(onsight: true).present?
        best_attempt = successful_attempts.where(onsight: true).first
        redpointed_text = "#{best_attempt.date.strftime('%m/%d/%Y')} (Onsight)"
      elsif successful_attempts.where(flash: true).present?
        best_attempt = successful_attempts.where(flash: true).first
        redpointed_text = "#{best_attempt.date.strftime('%m/%d/%Y')} (Flash)"
      else
        best_attempt = successful_attempts.first
        redpointed_text = best_attempt.date.strftime('%m/%d/%Y')
      end
    end
    return redpointed_text
  end

  def length_unit_short
    short_unit = nil
    if self.length_unit == "feet"
      short_unit = "ft"
    elsif self.length_unit == "meters"
      short_unit = "m"
    end
    return short_unit
  end

  def grade_string
    return Climb.climbing_grade_conversion_western[self.grade].with_indifferent_access[self.climb_type]
  end

  def self.convert_score_to_grades(score, format="western")
    if format == "western"
      scores = self.climbing_grade_conversion_western.keys
      closest_score = scores.min_by { |x| (x.to_f - score).abs }
      closest_grade = self.climbing_grade_conversion_western[closest_score]
    else
      scores = self.climbing_grade_conversion_european.keys
      closest_score = scores.min_by { |x| (x.to_f - score).abs }
      closest_grade = self.climbing_grade_conversion_european[closest_score]
    end
    return "#{closest_grade[:boulder]} / #{closest_grade[:sport]}"
  end

  def self.climbing_grade_conversion_western
    conversion = {1 => {"boulder": "VB-", "sport": "5.5", "trad": "5.5"},
                  5 => {"boulder": "VB-", "sport": "5.6", "trad": "5.6"},
                  10 => {"boulder": "VB", "sport": "5.7", "trad": "5.7"},
                  15 => {"boulder": "V0", "sport": "5.8", "trad": "5.8"},
                  20 => {"boulder": "V1", "sport": "5.9", "trad": "5.9"},
                  25 => {"boulder": "V2", "sport": "5.10a", "trad": "5.10a"},
                  30 => {"boulder": "V3-", "sport": "5.10b", "trad": "5.10b"},
                  35 => {"boulder": "V3", "sport": "5.10c", "trad": "5.10c"},
                  40 => {"boulder": "V4-", "sport": "5.10d", "trad": "5.10d"},
                  45 => {"boulder": "V4", "sport": "5.11a", "trad": "5.11a"},
                  50 => {"boulder": "V5-", "sport": "5.11b", "trad": "5.11b"},
                  55 => {"boulder": "V5", "sport": "5.11c", "trad": "5.11c"},
                  60 => {"boulder": "V6-", "sport": "5.11d", "trad": "5.11d"},
                  65 => {"boulder": "V6", "sport": "5.12a", "trad": "5.12a"},
                  70 => {"boulder": "V7-", "sport": "5.12b", "trad": "5.12b"},
                  75 => {"boulder": "V7", "sport": "5.12c", "trad": "5.12c"},
                  80 => {"boulder": "V8-", "sport": "5.12d", "trad": "5.12d"},
                  85 => {"boulder": "V8", "sport": "5.13a", "trad": "5.13a"},
                  90 => {"boulder": "V9-", "sport": "5.13b", "trad": "5.13b"},
                  95 => {"boulder": "V9", "sport": "5.13c", "trad": "5.13c"},
                  100 => {"boulder": "V10", "sport": "5.13d", "trad": "5.13d"},
                  105 => {"boulder": "V11", "sport": "5.14a", "trad": "5.14a"},
                  110 => {"boulder": "V12", "sport": "5.14b", "trad": "5.14b"},
                  115 => {"boulder": "V13", "sport": "5.14c", "trad": "5.14c"},
                  120 => {"boulder": "V14", "sport": "5.14d", "trad": "5.14d"},
                  125 => {"boulder": "V15", "sport": "5.15a", "trad": "5.15a"},
                  130 => {"boulder": "V16", "sport": "5.15b", "trad": "5.15b"},
                  135 => {"boulder": "V17", "sport": "5.15c", "trad": "5.15c"},
                  140 => {"boulder": "V18", "sport": "5.15d", "trad": "5.15d"}}
    return conversion
  end

  def self.climbing_grade_conversion_european
    conversion = {1 => {"boulder": "1", "sport": "4b", "trad": "4b"},
                  5 => {"boulder": "2", "sport": "4c", "trad": "4c"},
                  10 => {"boulder": "3", "sport": "5a", "trad": "5a"},
                  15 => {"boulder": "4", "sport": "5b", "trad": "5b"},
                  20 => {"boulder": "5", "sport": "5c", "trad": "5c"},
                  25 => {"boulder": "5+", "sport": "6a", "trad": "6a"},
                  30 => {"boulder": "6A", "sport": "6a+", "trad": "6a+"},
                  35 => {"boulder": "6A+", "sport": "6b", "trad": "6b"},
                  40 => {"boulder": "6B", "sport": "6b+", "trad": "6b+"},
                  45 => {"boulder": "6B+", "sport": "6b+", "trad": "6b+"},
                  50 => {"boulder": "6C", "sport": "6c", "trad": "6c"},
                  55 => {"boulder": "6C+", "sport": "6c+", "trad": "6c+"},
                  60 => {"boulder": "6C+", "sport": "7a", "trad": "7a"},
                  65 => {"boulder": "7A", "sport": "7a+", "trad": "7a+"},
                  70 => {"boulder": "7A", "sport": "7b", "trad": "7b"},
                  75 => {"boulder": "7A+", "sport": "7b+", "trad": "7b+"},
                  80 => {"boulder": "7B", "sport": "7c", "trad": "7c"},
                  85 => {"boulder": "7B+", "sport": "7c+", "trad": "7c+"},
                  90 => {"boulder": "7B+", "sport": "8a", "trad": "8a"},
                  95 => {"boulder": "7C", "sport": "8a+", "trad": "8a+"},
                  100 => {"boulder": "7C+", "sport": "8b", "trad": "8b"},
                  105 => {"boulder": "8A", "sport": "8b+", "trad": "8b+"},
                  110 => {"boulder": "8A+", "sport": "8c", "trad": "8c"},
                  115 => {"boulder": "8B", "sport": "8c+", "trad": "8c+"},
                  120 => {"boulder": "8B+", "sport": "9a", "trad": "9a"},
                  125 => {"boulder": "8C", "sport": "9a+", "trad": "9a+"},
                  130 => {"boulder": "8C+", "sport": "9b", "trad": "9b"},
                  135 => {"boulder": "9A", "sport": "9b+", "trad": "9b+"},
                  140 => {"boulder": "9A+", "sport": "9c", "trad": "9c"}}
    return conversion
  end

  def self.bouldering_grades(european=false)
    if european
      grade_conversion = self.climbing_grade_conversion_european
      useful_grades = [10, 15, 20, 30, 35, 40, 45, 50, 55, 65, 75, 80, 85, 95, 100, 105, 110, 115, 120, 125, 130]
    else
      grade_conversion = self.climbing_grade_conversion_western
      useful_grades = [10, 15, 20, 25, 35, 45, 55, 65, 75, 85, 95, 100, 105, 110, 115, 120, 125, 130]
    end

    useful_conversions = grade_conversion.select{|key,value| useful_grades.include? key}
    return useful_conversions.map{ |key, value| [value[:boulder], key] }
  end

  def self.sport_grades(european=false)
    if european
      grade_conversion = self.climbing_grade_conversion_european
      useful_grades = grade_conversion.map{ |key, value| key }
      useful_grades.delete(135)
      useful_grades.delete(140)
    else
      grade_conversion = self.climbing_grade_conversion_western
      useful_grades = grade_conversion.map{ |key, value| key }
      useful_grades.delete(40)
      useful_grades.delete(135)
      useful_grades.delete(140)
    end

    useful_conversions = grade_conversion.select{|key,value| useful_grades.include? key}
    return useful_conversions.map{ |key, value| [value[:sport], key] }
  end

end
