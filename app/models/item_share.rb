class ItemShare < ActiveRecord::Base
  belongs_to :item, polymorphic: true
  belongs_to :sharer, class_name: 'User', foreign_key: 'sharer_id'
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id'
  after_create :send_email

  def send_email
    if self.sent.blank?
      UserMailer.share_email(self).deliver_now
      self.sent = true
      self.save
    end
  end

  def smart_item_type
    item_type = self.item_type
    if item_type.downcase == "macrocycle"
      item_type = "Plan"
    end
    return item_type
  end


end
