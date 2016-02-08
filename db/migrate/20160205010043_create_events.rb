class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :start_date, default: DateTime.now
      t.datetime :end_date, default: DateTime.now
      t.string :label
      t.string :event_type
      t.integer :perception
      t.text :notes
      t.boolean :completed, default: false
      t.references :parent_event, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.references :workout, index: true, foreign_key: true
      t.references :microcycle, index: true, foreign_key: true
      t.references :mesocycle, index: true, foreign_key: true
      t.references :macrocycle, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
