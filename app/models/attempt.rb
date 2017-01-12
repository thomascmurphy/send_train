class Attempt < ActiveRecord::Base
  belongs_to :climb
  has_many :votes, as: :voteable

  def set_date_to_now
    self.date = DateTime.now
  end
end
