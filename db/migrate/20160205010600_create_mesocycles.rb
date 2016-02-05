class CreateMesocycles < ActiveRecord::Migration
  def change
    create_table :mesocycles do |t|
      t.references :event, index: true, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date
      t.string :label
      t.integer :reference_id
      t.string :type

      t.timestamps null: false
    end
  end
end
