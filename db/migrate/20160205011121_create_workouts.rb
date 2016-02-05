class CreateWorkouts < ActiveRecord::Migration
  def change
    create_table :workouts do |t|
      t.references :microcycle, index: true, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date
      t.string :label
      t.integer :reference_id
      t.string :type

      t.timestamps null: false
    end
  end
end
