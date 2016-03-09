class UserCoach < ActiveRecord::Base
  belongs_to :user
  belongs_to :coach, class_name: 'User', foreign_key: 'coach_id'
end
