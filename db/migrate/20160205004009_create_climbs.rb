class CreateClimbs < ActiveRecord::Migration
  def change
    create_table :climbs do |t|
      t.references :user, index: true, foreign_key: true
      t.string :climb_type
      t.integer :grade
      t.string :location
      t.string :name
      t.integer :length
      t.string :length_unit
      t.boolean :outdoor, default: true
      t.boolean :crimpy, default: false
      t.boolean :slopey, default: false
      t.boolean :pinchy, default: false
      t.boolean :pockety, default: false
      t.boolean :powerful, default: false
      t.boolean :dynamic, default: false
      t.boolean :endurance, default: false
      t.boolean :technical, default: false
      t.text :notes

      t.timestamps null: false
    end
  end
end
