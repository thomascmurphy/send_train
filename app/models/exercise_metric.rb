class ExerciseMetric < ActiveRecord::Base
  belongs_to :exercise_metric_type
  belongs_to :user
  belongs_to :exercise
  has_many :exercise_metric_options, dependent: :destroy
  after_save :cleanup_options

  def cleanup_options
    unless self.exercise_metric_type.label == "Hold Type"
      if self.exercise_metric_options.present?
        self.exercise_metric_options.destroy_all
      end
    end
  end
end
