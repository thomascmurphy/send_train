class Attempt < ActiveRecord::Base
  belongs_to :climb

  def set_date_to_now
    self.date = DateTime.now
  end
end
