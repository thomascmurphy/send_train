class Attempt < ActiveRecord::Base
  belongs_to :climb
  has_many :votes, as: :voteable

  def set_date_to_now
    self.date = DateTime.now
  end

  def from_mountain_project(params)
    if params["notes"] == "Onsight"
      self.completion = 100
      self.onsight = true
    elsif params["notes"] == "Flash"
      self.completion = 100
      self.flash = true
    elsif params["notes"] == "Fell/Hung"
      self.completion = 50
    else
      self.completion = 100
    end
    self
  end

end
