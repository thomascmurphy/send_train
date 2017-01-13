class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :voteable, polymorphic: true

    def self.item_score(voteable)
      voteable.votes.sum(:value)
    end

    def self.item_upvoted_by_user(voteable, user_id)
      Vote.where(user_id: user_id, voteable: voteable, value: 1).count > 0
    end

    def self.item_downvoted_by_user(voteable, user_id)
      Vote.where(user_id: user_id, voteable: voteable, value: -1).count > 0
    end

    def self.item_auto_upvote(voteable)
      Vote.create(voteable: voteable, user: voteable.user, value: 1)
    end
end
