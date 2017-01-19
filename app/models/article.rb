class Article < ActiveRecord::Base
  belongs_to :user
  has_many :votes, as: :voteable, dependent: :destroy
  has_many :messages, as: :messageable, dependent: :destroy
end
