class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :label
      t.string :event_type
      t.integer :perception
      t.text :notes
      t.boolean :completed, default: false
      t.integer :parent_event_id, index: true
      t.references :user, index: true, foreign_key: true
      t.references :workout, index: true, foreign_key: true
      t.references :microcycle, index: true, foreign_key: true
      t.references :mesocycle, index: true, foreign_key: true
      t.references :macrocycle, index: true, foreign_key: true
      t.string :gym_session

      t.timestamps null: false
    end
  end
end
