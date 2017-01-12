class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent_message
  belongs_to :parent_message, class_name: 'Message', foreign_key: 'parent_message_id'
  has_many :replies, class_name: 'Message', foreign_key: 'parent_message_id', dependent: :destroy
  belongs_to :messageable, polymorphic: true
  has_many :votes, as: :voteable
  after_create :auto_upvote, :transfer_messageable

  def auto_upvote
    Vote.item_auto_upvote(self)
  end

  def transfer_messageable
    if self.parent_message.present? && self.parent_message.messageable.present?
      self.update_attributes({messageable_id: self.parent_message.messageable_id, messageable_type: self.parent_message.messageable_type})
    end
  end

  def replies_ordered
    self.replies.sort_by{|x| [Vote.item_score(x), x.updated_at]}.reverse
  end

  def self.item_messages_ordered(messageable)
    messageable.messages.where(parent_message_id: nil).sort_by{|x| [Vote.item_score(x), x.updated_at]}.reverse
  end

  def smart_title
    if self.title.present?
      self.title
    elsif self.messageable.present?
      case self.messageable_type
      when "User"
        "From #{self.user.smart_name}"
      when "Exercise"
        "Re: Exercise \"#{self.messageable.label}\""
      when "Workout"
        "Re: Workout \"#{self.messageable.label}\""
      when "Macrocycle"
        "Re: Plan \"#{self.messageable.label}\""
      when "Goal"
        "Re: Goal \"#{self.messageable.label}\""
      else

      end
    elsif self.parent_message.present?
      "Re: #{self.parent_message.user.smart_name}'s message"
    else
    end
  end

  def smart_creation_title
    if self.title.present?
      self.title
    elsif self.messageable.present?
      case self.messageable_type
      when "User"
        "Message #{self.user.smart_name}"
      when "Exercise"
        "Discuss Exercise \"#{self.messageable.label}\""
      when "Workout"
        "Discuss Workout \"#{self.messageable.label}\""
      when "Macrocycle"
        "Discuss Plan \"#{self.messageable.label}\""
      when "Goal"
        "Discuss Goal \"#{self.messageable.label}\""
      else

      end
    elsif self.parent_message.present?
      "Respond to #{self.parent_message.user.smart_name}'s message"
    else
    end
  end

  def belongs_to_user(user)
    self.messageable == user || (self.messageable.present? && self.messageable.user == user)
  end

end
