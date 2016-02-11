class AddGymSessionToEvents < ActiveRecord::Migration
  def change
    add_column :events, :gym_session, :string
  end
end
