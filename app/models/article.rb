class Article < ActiveRecord::Base
  belongs_to :user
  has_many :votes, as: :voteable
  has_many :messages, as: :messageable
end
