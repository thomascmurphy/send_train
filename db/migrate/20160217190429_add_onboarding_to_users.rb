class AddOnboardingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :onboarding_step, :integer, default: 0
  end
end
