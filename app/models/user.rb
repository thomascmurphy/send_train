class User < ActiveRecord::Base
  has_many :climbs
  has_many :attempts, through: :climbs
  has_many :events
  has_many :mesocycles, through: :events
  has_many :microcycles, through: :mesocycles
  has_many :workouts, through: :microcycles

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
