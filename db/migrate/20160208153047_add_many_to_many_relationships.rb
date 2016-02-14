class AddManyToManyRelationships < ActiveRecord::Migration
  def change
    create_table :microcycles_workouts, id: false do |t|
      t.belongs_to :workout, index: true
      t.belongs_to :microcycle, index: true
    end

    create_table :mesocycles_microcycles, id: false do |t|
      t.belongs_to :microcycle, index: true
      t.belongs_to :mesocycle, index: true
    end

    create_table :macrocycles_mesocycles, id: false do |t|
      t.belongs_to :macrocycle, index: true
      t.belongs_to :mesocycle, index: true
    end

    create_table :macrocycle_workouts do |t|
      t.belongs_to :macrocycle, index: true
      t.belongs_to :workout, index: true
      t.integer :order_in_day
      t.integer :day_in_cycle
    end
  end
end
