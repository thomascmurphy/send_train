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
end
